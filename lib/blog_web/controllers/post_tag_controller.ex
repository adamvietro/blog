defmodule BlogWeb.Post_TagController do
  use BlogWeb, :controller

  alias Blog.Post_Tags
  alias Blog.Post_Tags.Post_Tag

  def index(conn, _params) do
    post_tags = Post_Tags.list_post_tags()
    render(conn, :index, post_tags: post_tags)
  end

  def new(conn, _params) do
    changeset = Post_Tags.change_post__tag(%Post_Tag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post__tag" => post__tag_params}) do
    case Post_Tags.create_post__tag(post__tag_params) do
      {:ok, post__tag} ->
        conn
        |> put_flash(:info, "Post  tag created successfully.")
        |> redirect(to: ~p"/post_tags/#{post__tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post__tag = Post_Tags.get_post__tag!(id)
    render(conn, :show, post__tag: post__tag)
  end

  def edit(conn, %{"id" => id}) do
    post__tag = Post_Tags.get_post__tag!(id)
    changeset = Post_Tags.change_post__tag(post__tag)
    render(conn, :edit, post__tag: post__tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post__tag" => post__tag_params}) do
    post__tag = Post_Tags.get_post__tag!(id)

    case Post_Tags.update_post__tag(post__tag, post__tag_params) do
      {:ok, post__tag} ->
        conn
        |> put_flash(:info, "Post  tag updated successfully.")
        |> redirect(to: ~p"/post_tags/#{post__tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post__tag: post__tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post__tag = Post_Tags.get_post__tag!(id)
    {:ok, _post__tag} = Post_Tags.delete_post__tag(post__tag)

    conn
    |> put_flash(:info, "Post  tag deleted successfully.")
    |> redirect(to: ~p"/post_tags")
  end
end
