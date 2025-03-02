defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Repo
  alias Blog.Comments.Comment
  alias Blog.Posts
  alias Blog.Comments

  def create(conn, %{"comment" => comment_params, "id" => post_id}) do
    updated = Map.put(comment_params, "post_id", post_id)

    case Comments.create_comment(updated) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}")

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

    # IO.inspect(comment_list)

    render(conn, :show, comment: comment_list)
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => _id, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    {:ok, _post} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
