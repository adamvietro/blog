defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  @create_attrs %{
    title: "some title",
    content: "some content",
    published_on: ~D[2025-02-15],
    visibility: true,
  }
  @update_attrs %{
    title: "some updated title",
    content: "some updated content",
    published_on: ~D[2025-02-16],
    visibility: false,
  }

  @invalid_attrs %{title: nil, content: nil, published_on: nil, visibility: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      post_user = user_fixture()
      conn = conn |> log_in_user(post_user) |> get(~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      post_user = user_fixture()
      conn = conn |> log_in_user(post_user)
      conn = post(conn, ~p"/posts", post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      post_user = user_fixture()
      conn = conn |> log_in_user(post_user)
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(user_id: user.id)
    %{post: post, user: user}
  end

  describe "search" do
    alias Blog.Posts, as: Posts

    import Blog.AccountsFixtures
    import Blog.PostsFixtures
    import Blog.AccountsFixtures

    test "search_posts/1 filters posts by partial and case-sensitive title" do
      user = user_fixture()
      post = post_fixture(user_id: user.id, title: "Title")

      # non-matching
      assert Posts.search_posts("Non-Matching") == []
      # exact match
      assert Posts.search_posts("Title") == [post]
      # partial match end
      assert Posts.search_posts("tle") == [post]
      # partial match front
      assert Posts.search_posts("Titl") == [post]
      # partial match middle
      assert Posts.search_posts("itl") == [post]
      # case insensitive lower
      assert Posts.search_posts("title") == []
      # case insensitive upper
      assert Posts.search_posts("TITLE") == []
      # case insensitive and partial match
      assert Posts.search_posts("ITL") == []
      # empty
      assert Posts.search_posts("") == [post]
    end
  end

  describe "html request search" do
    test "search for posts - non-matching", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, title: "some title")
      conn = get(conn, ~p"/search", title: "Non-Matching")
      refute html_response(conn, 200) =~ post.title
    end

    test "search for posts - exact match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, title: "some title")
      conn = get(conn, ~p"/search", title: "some title")
      assert html_response(conn, 200) =~ post.title
    end

    test "search for posts - partial match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, title: "some title")
      conn = get(conn, ~p"/search", title: "itl")
      assert html_response(conn, 200) =~ post.title
    end
  end
end
