defmodule BlogWeb.SearchController do
  use BlogWeb, :controller

  alias Blog.Posts

  def search(conn, %{"title" => title}) do
    ids =
      Enum.reduce(Posts.list_posts(), [], fn post, list ->
        if post.title =~ title do
          [post.id | list]
        end
      end)

    matching_posts =
      Enum.map(ids, fn id ->
        Posts.get_post!(id)
      end)

    render(conn, :search, post: matching_posts)
  end
end
