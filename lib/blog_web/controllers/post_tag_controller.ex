defmodule BlogWeb.Post_TagController do
  use BlogWeb, :controller

  alias Blog.Post_Tags
  alias Blog.Post_Tags.Post_Tag

  def index(conn, _params) do
    post_tags = Post_Tags.list_post_tags()
    render(conn, :index, post_tags: post_tags)
  end

  def new(conn, _params) do
    changeset = Post_Tags.change_post_tag(%Post_Tag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post_tag" => post_tag_params}) do
    case Post_Tags.create_post_tag(post_tag_params) do
      {:ok, post_tag} ->
        conn
        |> put_flash(:info, "Post  tag created successfully.")
        |> redirect(to: ~p"/post_tags/#{post_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post_tag = Post_Tags.get_post_tag!(id)
    render(conn, :show, post_tag: post_tag)
  end

  def edit(conn, %{"id" => id}) do
    post_tag = Post_Tags.get_post_tag!(id)
    changeset = Post_Tags.change_post_tag(post_tag)
    render(conn, :edit, post_tag: post_tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post_tag" => post_tag_params}) do
    post_tag = Post_Tags.get_post_tag!(id)

    case Post_Tags.update_post_tag(post_tag, post_tag_params) do
      {:ok, post_tag} ->
        conn
        |> put_flash(:info, "Post  tag updated successfully.")
        |> redirect(to: ~p"/post_tags/#{post_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post_tag: post_tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post_tag = Post_Tags.get_post_tag!(id)
    {:ok, _post_tag} = Post_Tags.delete_post_tag(post_tag)

    conn
    |> put_flash(:info, "Post  tag deleted successfully.")
    |> redirect(to: ~p"/post_tags")
  end
end
