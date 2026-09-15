defmodule BlogWeb.RobotsTest do
  use BlogWeb.ConnCase

  test "GET /robots.txt points crawlers at the sitemap and disallows admin-only sections", %{
    conn: conn
  } do
    conn = get(conn, "/robots.txt")

    body = response(conn, 200)
    assert body =~ "Sitemap: https://blog-wild-leaf-1554.fly.dev/sitemap.xml"
    assert body =~ "Disallow: /dev/"
    assert body =~ "Disallow: /users/"
    assert body =~ "Disallow: /tags/"
  end
end
