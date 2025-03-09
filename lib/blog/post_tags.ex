# defmodule Blog.Post_Tags do
#   @moduledoc """
#   The Post_Tags context.
#   """

#   import Ecto.Query, warn: false
#   alias Blog.Repo

#   alias Blog.Post_Tags.Post_Tag

#   @doc """
#   Returns the list of post_tags.

#   ## Examples

#       iex> list_post_tags()
#       [%Post_Tag{}, ...]

#   """
#   def list_post_tags do
#     Repo.all(Post_Tag)
#   end

#   @doc """
#   Gets a single post_tag.

#   Raises `Ecto.NoResultsError` if the Post  tag does not exist.

#   ## Examples

#       iex> get_post_tag!(123)
#       %Post_Tag{}

#       iex> get_post_tag!(456)
#       ** (Ecto.NoResultsError)

#   """
#   def get_post_tag!(id), do: Repo.get!(Post_Tag, id)

#   @doc """
#   Creates a post_tag.

#   ## Examples

#       iex> create_post_tag(%{field: value})
#       {:ok, %Post_Tag{}}

#       iex> create_post_tag(%{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def create_post_tag(attrs \\ %{}) do
#     %Post_Tag{}
#     |> Post_Tag.changeset(attrs)
#     |> Repo.insert()
#   end

#   @doc """
#   Updates a post_tag.

#   ## Examples

#       iex> update_post_tag(post_tag, %{field: new_value})
#       {:ok, %Post_Tag{}}

#       iex> update_post_tag(post_tag, %{field: bad_value})
#       {:error, %Ecto.Changeset{}}

#   """
#   def update_post_tag(%Post_Tag{} = post_tag, attrs) do
#     post_tag
#     |> Post_Tag.changeset(attrs)
#     |> Repo.update()
#   end

#   @doc """
#   Deletes a post_tag.

#   ## Examples

#       iex> delete_post_tag(post_tag)
#       {:ok, %Post_Tag{}}

#       iex> delete_post_tag(post_tag)
#       {:error, %Ecto.Changeset{}}

#   """
#   def delete_post_tag(%Post_Tag{} = post_tag) do
#     Repo.delete(post_tag)
#   end

#   @doc """
#   Returns an `%Ecto.Changeset{}` for tracking post_tag changes.

#   ## Examples

#       iex> change_post_tag(post_tag)
#       %Ecto.Changeset{data: %Post_Tag{}}

#   """
#   def change_post_tag(%Post_Tag{} = post_tag, attrs \\ %{}) do
#     Post_Tag.changeset(post_tag, attrs)
#   end
# end
