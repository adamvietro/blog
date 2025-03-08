defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  import Blog.Tags

  alias Blog.Posts
  alias Blog.Posts.Post

  plug :require_user_owns_post when action in [:edit, :update, :delete]

  # Typically Goes At The Bottom Of The File
  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own posts.")
      |> redirect(to: ~p"/posts/#{post_id}")
      |> halt()
    end
  end

  defp tag_options(selected_ids \\ []) do
    list_tags()
    |> Enum.map(fn tag ->
      [key: tag.tag, value: tag.id, selected: tag.id in selected_ids]
    end)
  end

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, :index, posts: posts)
  end

  @spec search(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def search(conn, %{"title" => title}) do
    matching_posts = Posts.search_posts(title)

    render(conn, :search_results, post: matching_posts)
  end

  def search(conn, _param) do
    render(conn, :search_form)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, :show, post: post)
  end

  @spec new(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def new(conn, _params) do
    tags = tag_options()
    changeset = Posts.change_post(%Post{})

    render(conn, :new, changeset: changeset, tags: tags)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"post" => post_params}) do
    post_params = Map.put(post_params, "user_id", conn.assigns[:current_user].id)

    IO.inspect(post_params)

    if post_params["tag_ids"] == nil do
      case Posts.create_post(post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post created successfully.")
          |> redirect(to: ~p"/posts/#{post}")

        {:error, %Ecto.Changeset{} = changeset} ->
          tags = tag_options()
          render(conn, :new, changeset: changeset, tags: tags)
      end
    else
      tags =
        Enum.map(post_params["tag_ids"], fn tag_id ->
          %{post_id: post_params["user_id"], tag_id: String.to_integer(tag_id)}
        end)
      IO.inspect(tags)

      case Posts.create_post(post_params, tags) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post created successfully.")
          |> redirect(to: ~p"/posts/#{post}")

        {:error, %Ecto.Changeset{} = changeset} ->
          tags = tag_options()
          render(conn, :new, changeset: changeset, tags: tags)
      end
    end
  end

  @spec edit(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    changeset = Posts.change_post(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  @spec put(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def put(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    if conn.assigns[:current_user].id == post.user_id do
      case Posts.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: ~p"/posts/#{post}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit, post: post, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "You can only edit your own posts.")
      |> redirect(to: ~p"/posts/#{id}")
      |> halt()
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    if conn.assigns[:current_user].id == post.user_id do
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: ~p"/posts")
    else
      conn
      |> put_flash(:error, "You can only delete your own posts.")
      |> redirect(to: ~p"/posts/#{id}")
      |> halt()
    end
  end
end
