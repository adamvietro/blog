defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post

  @doc """
  Returns the list of posts.

  Unpublished (`visibility: false`) posts and posts scheduled for a future
  `published_on` date are excluded unless `current_user` is an admin, who
  can see every post regardless of either.

  Pass `page:` (1-based) and optionally `per_page:` (default 10) in `opts`
  to get one page of results instead of everything — see `count_posts/1` to
  compute how many pages there are.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

      iex> list_posts(current_user, page: 2, per_page: 10)
      [%Post{}, ...]

  """
  def list_posts(current_user \\ nil, opts \\ []) do
    Post
    |> filter_visibility(current_user)
    |> filter_scheduled(current_user)
    |> order_by(desc: :inserted_at)
    |> paginate(opts)
    |> Repo.all()
    |> Repo.preload([:tags, :cover_image])
  end

  @doc """
  Counts the posts `list_posts/2` would return for this `current_user`,
  ignoring pagination — use this to compute a total page count.
  """
  def count_posts(current_user \\ nil) do
    Post
    |> filter_visibility(current_user)
    |> filter_scheduled(current_user)
    |> Repo.aggregate(:count)
  end

  defp filter_visibility(query, %{admin: true}), do: query
  defp filter_visibility(query, _current_user), do: where(query, [p], p.visibility == true)

  defp filter_scheduled(query, %{admin: true}), do: query

  defp filter_scheduled(query, _current_user),
    do: where(query, [p], p.published_on <= ^Date.utc_today())

  defp paginate(query, opts) do
    case Keyword.get(opts, :page) do
      nil ->
        query

      page ->
        per_page = Keyword.get(opts, :per_page, 10)

        query
        |> limit(^per_page)
        |> offset(^((page - 1) * per_page))
    end
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, tags \\ []) do
    %Post{}
    |> Post.changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, tags \\ []) do
    post
    |> Repo.preload([:cover_image])
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}, tags \\ []) do
    post
    |> Repo.preload(:cover_image)
    |> Post.changeset(attrs, tags)
  end

  @doc """
  Returns a list of posts that match (title or content) or partially match the given search field.
  Also has a check for the visibility field.

  ## Examples
      iex> search_posts(title)
      [%Post{}, ...]

  """
  def search_posts(search_field) do
    search_field = String.downcase(search_field)

    Enum.reduce(list_posts(), [], fn post, ids ->
      post_title = String.downcase(post.title)
      comment_field = String.downcase(post.content)

      cond do
        post_title =~ search_field and post.visibility ->
          [post | ids]

        search_field =~ comment_field and post.visibility ->
          [post | ids]

        true ->
          ids
      end
    end)
  end
end
