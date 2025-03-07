defmodule Blog.Post_TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Post_Tags` context.
  """

  @doc """
  Generate a post_tag.
  """
  def post_tag_fixture(attrs \\ %{}) do
    {:ok, post_tag} =
      attrs
      |> Enum.into(%{

      })
      |> Blog.Post_Tags.create_post_tag()

    post_tag
  end
end
