defmodule BlogWeb.SitemapController do
  use BlogWeb, :controller

  alias Blog.Posts

  @doc """
  Renders a sitemap.xml listing the public pages: home, the post index, and
  every published post.
  """
  def index(conn, _params) do
    posts = Posts.list_posts(nil)

    xml = render_sitemap(posts)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml)
  end

  defp render_sitemap(posts) do
    static_urls =
      Enum.map_join([url(~p"/"), url(~p"/posts")], "\n", &url_entry(&1, nil))

    post_urls =
      Enum.map_join(posts, "\n", fn post ->
        url_entry(url(~p"/posts/#{post}"), post.updated_at)
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{static_urls}
    #{post_urls}
    </urlset>
    """
    |> String.trim()
  end

  defp url_entry(loc, nil) do
    """
      <url>
        <loc>#{loc}</loc>
      </url>
    """
    |> String.trim_trailing()
  end

  defp url_entry(loc, %DateTime{} = last_modified) do
    """
      <url>
        <loc>#{loc}</loc>
        <lastmod>#{Date.to_iso8601(DateTime.to_date(last_modified))}</lastmod>
      </url>
    """
    |> String.trim_trailing()
  end
end
