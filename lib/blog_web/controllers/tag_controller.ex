defmodule BlogWeb.TagController do
  use BlogWeb, :controller

  alias Blog.Tags
  alias Blog.Tags.Tag
  alias Blog.Posts
  alias Blog.Repo

  plug :require_admin
       when action in [:edit, :update, :delete, :new, :create]

  def index(conn, _params) do
    tags = Tags.list_tags()
    render(conn, :index, tags: tags)
  end

  def new(conn, _params) do
    changeset = Tags.change_tag(%Tag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"tag" => tag_params}) do
    case Tags.create_tag(tag_params) do
      {:ok, _tag} ->
        conn
        |> put_flash(:info, "Tag created successfully.")
        |> redirect(to: ~p"/tags")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    render(conn, :show, tag: tag)
  end

  def edit(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    changeset = Tags.change_tag(tag)
    render(conn, :edit, tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Tags.get_tag!(id)

    case Tags.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(to: ~p"/tags/#{tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, tag: tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    {:ok, _tag} = Tags.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: ~p"/tags")
  end

  def search(conn, %{"tag" => search_tag}) do
    posts =
      Posts.list_posts()
      |> Repo.preload([:tags])

    post =
      Enum.map(posts, fn post ->
        tags =
          Enum.map(post.tags, fn tag ->
            tag.id
          end)

        if String.to_integer(search_tag) in tags do
          post
        else
        end
      end)
      |> Enum.filter(&(&1 != nil))

    render(conn, :search_results, posts: post)
  end

  def search(conn, _params) do
    render(conn, :search, tag_options: tag_options())
  end

  defp require_admin(conn, _opts) do
    if conn.assigns.current_user && conn.assigns.current_user.admin do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: ~p"/posts/")
      |> halt()
    end
  end

  defp tag_options(selected_ids \\ []) do
    Tags.list_tags()
    |> Enum.map(fn tag ->
      [key: tag.name, value: tag.id, selected: tag.id in selected_ids]
    end)
  end
end
