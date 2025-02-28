defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Repo
  alias Blog.Comments.Comment
  alias Blog.Posts
  alias Blog.Comments

  @moduledoc """
  Add the documentation here please.
  """

  # def create(conn, %{"comment" => comment_params}) do
  #   IO.inspect(comment_params)
  #   case Comments.create_comment(comment_params) do
  #     {:ok, comment} ->
  #       conn
  #       |> put_flash(:info, "Comment created successfully.")
  #       # redirect to the post show page where the comment form is rendered
  #       |> redirect(to: ~p"/posts/#{comment.post_id}")

  #     {:error, %Ecto.Changeset{} = comment_changeset} ->
  #       post = Posts.get_post!(comment_params["post_id"])

  #       # re-render the post show page with a comment changeset that the page uses to display errors.
  #       render(conn, :create, post: post, comment_changeset: comment_changeset)
  #   end
  # end

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

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    comments = Repo.preload(post, :comments)
    comment_list = Enum.map(comments.comments, fn comment ->
      comment.content
    end)

    render(conn, :show, comment: comment_list)
  end
end
