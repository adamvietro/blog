defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Posts
  alias Blog.Comments

  @moduledoc """
    get "/comments/:id", CommentController, :show
    post "/comments/:id", CommentCOntroller, :new

    Be sure to add the new controllers and then the html style sheets.
  """

  def create(conn, %{"comment" => comment_params}) do
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        # redirect to the post show page where the comment form is rendered
        |> redirect(to: ~p"/posts/#{comment.post_id}")

      {:error, %Ecto.Changeset{} = comment_changeset} ->
        post = Posts.get_post!(comment_params["post_id"])
        # re-render the post show page with a comment changeset that the page uses to display errors.
        render(conn, :show, post: post, comment_changeset: comment_changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    Comments.get_comment!(id)

    # Repo.preload(post, :comments)

    render(conn, :show)
  end

end
