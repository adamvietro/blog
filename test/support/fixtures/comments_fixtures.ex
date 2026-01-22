defmodule Blog.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    user_id = attrs[:user_id] || raise "user_id is required for comment_fixture"
    post_id = attrs[:post_id] || raise "post_id is required for comment_fixture"

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content",
        user_id: user_id,
        post_id: post_id
      })
      |> Blog.Comments.create_comment()

    comment
  end
end
