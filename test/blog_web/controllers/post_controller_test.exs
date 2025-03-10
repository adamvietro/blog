defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  alias Blog.Repo, as: Repo

  import Blog.PostsFixtures
  import Blog.AccountsFixtures
  import Blog.TagsFixtures

  @create_attrs %{
    title: "some title",
    content: "some content",
    published_on: ~D[2025-02-15],
    visibility: true
  }
  @update_attrs %{
    title: "some updated title",
    content: "some updated content",
    published_on: ~D[2025-02-16],
    visibility: false
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
      post = post |> Repo.preload([:cover_image])
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

    test "search_posts/1 filters posts by partial and case-sensitive title" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id, title: "Title")
        |> Repo.preload([:tags])

      # non-matching
      assert Posts.search_posts("Non-Matching") == []
      # exact match
      assert Posts.search_posts("Title") |> Repo.preload([:tags]) == [post]
      # partial match end
      assert Posts.search_posts("tle") |> Repo.preload([:tags]) == [post]
      # partial match front
      assert Posts.search_posts("Titl") |> Repo.preload([:tags]) == [post]
      # partial match middle
      assert Posts.search_posts("itl") |> Repo.preload([:tags]) == [post]
      # case insensitive lower
      assert Posts.search_posts("title") == []
      # case insensitive upper
      assert Posts.search_posts("TITLE") == []
      # case insensitive and partial match
      assert Posts.search_posts("ITL") == []
      # empty
      assert Posts.search_posts("") |> Repo.preload([:tags]) == [post]
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

  describe "Create with tags add comment then delete a Post" do
    alias Blog.Posts
    alias Blog.Posts.Post
    alias Blog.Comments
    alias Blog.Comments.Comment

    test "create_post/1 with tags", %{conn: conn} do
      user = user_fixture()
      tag1 = tag_fixture()
      tag2 = tag_fixture(%{name: "some other tag"})

      valid_attrs1 = %{
        content: "some content",
        title: "post 1",
        user_id: user.id,
        published_on: ~D[2025-02-15]
      }

      valid_attrs2 = %{
        content: "some content",
        title: "post 2",
        user_id: user.id,
        published_on: ~D[2025-02-15]
      }

      conn |> log_in_user(user)

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1, tag2])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      assert Repo.preload(post1, :tags).tags == [tag1, tag2]
      assert Repo.preload(post2, :tags).tags == [tag1]

      assert Repo.preload(tag1, posts: [:tags]).posts == [post1, post2]
      assert Repo.preload(tag2, posts: [:tags]).posts == [post1]

      valid_comment1 = %{content: "some content", post_id: post1.id, user_id: user.id}
      valid_comment2 = %{content: "some other content", post_id: post1.id, user_id: user.id}

      assert {:ok, %Comment{} = _comment} = Comments.create_comment(valid_comment1)
      assert {:ok, %Comment{} = _comment} = Comments.create_comment(valid_comment2)
    end

    test "a user cannot delete another user's post", %{conn: conn} do
      post_user = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: post_user.id)
      conn = conn |> log_in_user(other_user) |> delete(~p"/posts/#{post}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own posts."

      assert redirected_to(conn) == ~p"/posts/#{post}"
    end
  end
end
