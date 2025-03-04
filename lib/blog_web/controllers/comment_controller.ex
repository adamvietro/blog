defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Repo
  alias Blog.Comments.Comment
  alias Blog.Posts
  alias Blog.Comments

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

  def create(conn, %{"comment" => comment_params, "id" => post_id}) do
    comment_params = Map.put(comment_params, "post_id", post_id)
    comment_params = Map.put(comment_params, "user_id", conn.assigns[:current_user].id)

    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}/comments")

      {:error, %Ecto.Changeset{} = comment_changeset} ->
        post = Posts.get_post!(post_id)
        render(conn, :show, post: post, comment_changeset: comment_changeset)
    end
  end

  @spec new(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def new(conn, %{"id" => id}) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, :create, changeset: changeset, id: id)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    post =
      Posts.get_post!(id)
      |> Repo.preload(:comments)

    comment_list =
      Enum.map(post.comments, fn comment ->
        %{"id" => comment.id, "comment" => comment.content}
      end)

    render(conn, :show, comment: comment_list)
  end

  def delete(conn, %{"id" => id, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)

    if conn.assigns[:current_user].id == comment.user_id do
      {:ok, _post} = Comments.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted successfully.")
      |> redirect(to: ~p"/posts")
    else
      conn
      |> put_flash(:error, "You can only delete your own comments.")
      |> redirect(to: ~p"/posts/#{id}/comments")
      |> halt()
    end
  end

  @spec edit(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def edit(conn, %{"id" => _id, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    changeset = Comments.change_comment(comment)
    render(conn, :edit, comment: comment, changeset: changeset)
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "comment_id" => comment_id, "comment" => comment_params}) do
    comment =
      Comments.get_comment!(comment_id)

    comment_params =
      Map.update!(comment_params, "post_id", fn _existing -> id end)
      |> Map.put("id", comment_id)

    if conn.assigns[:current_user].id == comment.user_id do
      case Comments.update_comment(comment, comment_params) do
        {:ok, comment} ->
          conn
          |> put_flash(:info, "Comment updated successfully.")
          |> redirect(to: ~p"/posts/#{comment.post_id}/comments/")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit, comment: comment, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "You can only update your own comments.")
      |> redirect(to: ~p"/posts/#{id}/comments")
      |> halt()
    end
  end
end
