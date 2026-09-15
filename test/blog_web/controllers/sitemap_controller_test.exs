defmodule BlogWeb.SitemapControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  test "GET /sitemap.xml lists the home page, post index, and published posts", %{conn: conn} do
    user = admin_fixture()
    post = post_fixture(user_id: user.id, visibility: true)

    conn = get(conn, ~p"/sitemap.xml")

    assert [content_type] = get_resp_header(conn, "content-type")
    assert content_type =~ "application/xml"

    body = response(conn, 200)
    assert body =~ "<urlset"
    assert body =~ ~p"/"
    assert body =~ ~p"/posts"
    assert body =~ ~p"/posts/#{post}"
  end

  test "excludes unpublished posts", %{conn: conn} do
    user = admin_fixture()
    post = post_fixture(user_id: user.id, visibility: false)

    conn = get(conn, ~p"/sitemap.xml")

    refute response(conn, 200) =~ ~p"/posts/#{post}"
  end
end
