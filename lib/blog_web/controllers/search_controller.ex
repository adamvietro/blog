defmodule BlogWeb.SearchController do
  use BlogWeb, :controller

  # alias Blog.Posts

  # def search(conn, %{"title" => title}) do
  #   matching_posts = Posts.search_posts(title)

  #   render(conn, :search_form, post: matching_posts)
  # end

  def search(conn, _param) do

    render(conn, :search)
  end
end
