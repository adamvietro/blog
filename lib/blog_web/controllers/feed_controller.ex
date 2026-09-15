defmodule BlogWeb.FeedController do
  use BlogWeb, :controller

  alias Blog.Posts

  @doc """
  Renders an RSS 2.0 feed of the most recent published posts.
  """
  def index(conn, _params) do
    posts =
      Posts.list_posts(nil)
      |> Enum.take(20)

    xml = render_feed(posts)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, xml)
  end

  defp render_feed(posts) do
    site_url = url(~p"/")

    items = Enum.map_join(posts, "\n", &render_item(&1, site_url))

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>adam.log</title>
        <link>#{site_url}</link>
        <description>A technical blog documenting my journey through the Elixir ecosystem.</description>
        <language>en-us</language>
        <atom:link href="#{url(~p"/feed.xml")}" rel="self" type="application/rss+xml" />
    #{items}
      </channel>
    </rss>
    """
    |> String.trim()
  end

  defp render_item(post, _site_url) do
    link = url(~p"/posts/#{post}")
    pub_date = post.published_on |> DateTime.new!(~T[00:00:00], "Etc/UTC") |> format_rfc822()

    html_content =
      post.content
      |> Earmark.as_html!(%Earmark.Options{breaks: true})
      |> escape_cdata()

    """
      <item>
        <title>#{xml_escape(post.title)}</title>
        <link>#{link}</link>
        <guid isPermaLink="true">#{link}</guid>
        <pubDate>#{pub_date}</pubDate>
        <description><![CDATA[#{html_content}]]></description>
      </item>
    """
    |> String.trim_trailing()
  end

  defp format_rfc822(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S +0000")
  end

  defp xml_escape(text) do
    text
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  # CDATA sections only need protecting from a literal "]]>" inside them.
  defp escape_cdata(html), do: String.replace(html, "]]>", "]]&gt;")
end
