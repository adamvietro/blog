defmodule BlogWeb.PostVisibilityTest do
  use BlogWeb.ConnCase

  import Blog.AccountsFixtures
  import Blog.PostsFixtures

  alias Blog.Posts
  # alias Blog.Repo

  defp post_length(string, max_chars \\ 25) do
    if String.length(string) > max_chars do
      String.slice(string, 0, max_chars)
    else
      string
    end
  end

  describe "viewing published vs unpublished posts" do
    test "published posts appear in index", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, visibility: true)

      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ post_length(post.title)
    end

    test "unpublished posts do not appear in index", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, visibility: false)

      conn = get(conn, ~p"/posts")
      refute html_response(conn, 200) =~ post.title
    end

    # test "unpublished posts appear in index for the author", %{conn: conn} do
    #   user = user_fixture()
    #   post = post_fixture(user_id: user.id, visibility: false)

    #   conn = log_in_user(conn, user)
    #   conn = get(conn, ~p"/posts")

    #   # Author should see their own unpublished posts
    #   assert html_response(conn, 200) =~ post_length(post.title)
    #   assert html_response(conn, 200) =~ "Draft"
    # end

    test "unpublished posts do not appear in index for other users", %{conn: conn} do
      author = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: author.id, visibility: false)

      conn = log_in_user(conn, other_user)
      conn = get(conn, ~p"/posts")

      refute html_response(conn, 200) =~ post.title
    end

    test "admin can see all posts in index including unpublished", %{conn: conn} do
      author = user_fixture()
      admin = admin_fixture()
      published_post = post_fixture(user_id: author.id, visibility: true)
      unpublished_post = post_fixture(user_id: author.id, visibility: false)

      conn = log_in_user(conn, admin)
      conn = get(conn, ~p"/posts")

      response = html_response(conn, 200)
      assert response =~ post_length(published_post.title)
      assert response =~ post_length(unpublished_post.title)
    end
  end

  # describe "viewing individual unpublished posts" do
  #   test "author can view their own unpublished post", %{conn: conn} do
  #     user = user_fixture()
  #     post = post_fixture(user_id: user.id, visibility: false)

  #     conn = log_in_user(conn, user)
  #     conn = get(conn, ~p"/posts/#{post.id}")

  #     assert html_response(conn, 200) =~ post.content
  #   end

  #   test "non-author cannot view unpublished post", %{conn: conn} do
  #     author = user_fixture()
  #     other_user = user_fixture()
  #     post = post_fixture(user_id: author.id, visibility: false)

  #     conn = log_in_user(conn, other_user)
  #     conn = get(conn, ~p"/posts/#{post.id}")

  #     assert html_response(conn, 404) =~ "Not Found"
  #   end

  #   test "unauthenticated user cannot view unpublished post", %{conn: conn} do
  #     author = user_fixture()
  #     post = post_fixture(user_id: author.id, visibility: false)

  #     conn = get(conn, ~p"/posts/#{post.id}")

  #     assert html_response(conn, 404) =~ "Not Found"
  #   end

  #   test "admin can view any unpublished post", %{conn: conn} do
  #     author = user_fixture()
  #     admin = admin_fixture()
  #     post = post_fixture(user_id: author.id, visibility: false)

  #     conn = log_in_user(conn, admin)
  #     conn = get(conn, ~p"/posts/#{post.id}")

  #     assert html_response(conn, 200) =~ post.content
  #   end
  # end

  # describe "scheduled posts (published_on in future)" do
  #   test "future scheduled posts do not appear in index", %{conn: conn} do
  #     user = user_fixture()
  #     future_date = Date.add(Date.utc_today(), 7)

  #     post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: future_date
  #       )

  #     conn = get(conn, ~p"/posts")
  #     refute html_response(conn, 200) =~ post.title
  #   end

  #   test "author can see their own scheduled posts", %{conn: conn} do
  #     user = user_fixture()
  #     future_date = Date.add(Date.utc_today(), 7)

  #     post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: future_date
  #       )

  #     conn = log_in_user(conn, user)
  #     conn = get(conn, ~p"/posts")

  #     response = html_response(conn, 200)
  #     assert response =~ post.title
  #     assert response =~ "Scheduled"
  #   end

  #   test "scheduled posts become visible on publication date", %{conn: conn} do
  #     user = user_fixture()
  #     today = Date.utc_today()

  #     post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: today
  #       )

  #     conn = get(conn, ~p"/posts")
  #     assert html_response(conn, 200) =~ post_length(post.title)
  #   end

  #   test "posts published in the past are visible", %{conn: conn} do
  #     user = user_fixture()
  #     past_date = Date.add(Date.utc_today(), -7)

  #     post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: past_date
  #       )

  #     conn = get(conn, ~p"/posts")
  #     assert html_response(conn, 200) =~ post_length(post.title)
  #   end
  # end

  # describe "list_posts/0 respects visibility" do
  #       test "only returns published posts" do
  #         user = user_fixture()

  #         published_post = post_fixture(user_id: user.id, visibility: true)
  #         _unpublished_post = post_fixture(user_id: user.id, visibility: false)

  #         posts = Posts.list_posts() |> Repo.preload([:tags])

  #   f      assert length(posts) == 1
  #         assert hd(posts).id == published_post.id
  #       end

  #   test "only returns posts with published_on <= today" do
  #     user = user_fixture()
  #     future_date = Date.add(Date.utc_today(), 7)

  #     current_post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: Date.utc_today()
  #       )

  #     _future_post =
  #       post_fixture(
  #         user_id: user.id,
  #         visibility: true,
  #         published_on: future_date
  #       )

  #     posts = Posts.list_posts() |> Repo.preload([:tags])

  #     assert length(posts) == 1
  #     assert hd(posts).id == current_post.id
  #   end
  # end

  # describe "search respects visibility" do
  #   test "search only returns published posts", %{conn: conn} do
  #     user = user_fixture()

  #     published =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Searchable Title",
  #         visibility: true
  #       )

  #     _unpublished =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Searchable Title Too",
  #         visibility: false
  #       )

  #     conn = get(conn, ~p"/search", title: "Searchable")
  #     response = html_response(conn, 200)

  #     assert response =~ published.title
  #     refute response =~ "Searchable Title Too"
  #   end

  #   test "search does not return future scheduled posts", %{conn: conn} do
  #     user = user_fixture()
  #     future_date = Date.add(Date.utc_today(), 7)

  #     current =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Current Post",
  #         visibility: true,
  #         published_on: Date.utc_today()
  #       )

  #     _future =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Future Post",
  #         visibility: true,
  #         published_on: future_date
  #       )

  #     conn = get(conn, ~p"/search", title: "Post")
  #     response = html_response(conn, 200)

  #     assert response =~ "Current Post"
  #     refute response =~ "Future Post"
  #   end

  #   test "author can search their own unpublished posts", %{conn: conn} do
  #     user = user_fixture()

  #     _published =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Published Post",
  #         visibility: true
  #       )

  #     unpublished =
  #       post_fixture(
  #         user_id: user.id,
  #         title: "Unpublished Post",
  #         visibility: false
  #       )

  #     conn = log_in_user(conn, user)
  #     conn = get(conn, ~p"/search", title: "Post")
  #     response = html_response(conn, 200)

  #     assert response =~ "Published Post"
  #     assert response =~ "Unpublished Post"
  #   end
  # end

  describe "visibility toggling" do
    # test "changing visibility from true to false hides post", %{conn: conn} do
    #   user = user_fixture()
    #   post = post_fixture(user_id: user.id, visibility: true)

    #   # Verify it's visible
    #   conn = get(conn, ~p"/posts")
    #   assert html_response(conn, 200) =~ post_length(post.title)

    #   # Update visibility
    #   {:ok, updated_post} = Posts.update_post(post, %{visibility: false})
    #   assert updated_post.visibility == false

    #   # Verify it's now hidden
    #   conn = build_conn()
    #   conn = get(conn, ~p"/posts")
    #   refute html_response(conn, 200) =~ post_length(post.title)
    # end

    test "changing visibility from false to true shows post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id, visibility: false)

      # Verify it's hidden
      conn = get(conn, ~p"/posts")
      refute html_response(conn, 200) =~ post.title

      # Update visibility
      {:ok, updated_post} = Posts.update_post(post, %{visibility: true})
      assert updated_post.visibility == true

      # Verify it's now visible
      conn = build_conn()
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ post_length(post.title)
    end
  end
end
