defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> Blog.Posts.create_post()

    post
  end

  # @doc """
  # Generate a post.
  # """
  # def post_fixture(attrs \\ %{}) do
  #   {:ok, post} =
  #     attrs
  #     |> Enum.into(%{
  #       content: "some content",
  #       published_on: ~D[2025-02-15],
  #       title: "some title",
  #       visibility: true
  #     })
  #     |> Blog.Posts.create_post()

  #   post
  # end
end
