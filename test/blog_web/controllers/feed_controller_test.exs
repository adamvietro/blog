defmodule BlogWeb.FeedControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  test "GET /feed.xml renders an RSS feed of published posts", %{conn: conn} do
    user = admin_fixture()
    post = post_fixture(user_id: user.id, title: "A Published Post", visibility: true)

    conn = get(conn, ~p"/feed.xml")

    assert [content_type] = get_resp_header(conn, "content-type")
    assert content_type =~ "application/rss+xml"
    body = response(conn, 200)
    assert body =~ "<rss"
    assert body =~ post.title
    assert body =~ ~p"/posts/#{post}"
  end

  test "excludes unpublished posts", %{conn: conn} do
    user = admin_fixture()
    post = post_fixture(user_id: user.id, title: "A Secret Draft", visibility: false)

    conn = get(conn, ~p"/feed.xml")

    refute response(conn, 200) =~ post.title
  end
end
