defmodule BlogWeb.CommentControllerTest do
  use BlogWeb.ConnCase

  import Blog.AccountsFixtures
  import Blog.PostsFixtures
  import Blog.CommentsFixtures

  alias Blog.Comments

  describe "new" do
    test "renders the new comment form for a logged-in user", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/comments/new")

      assert html_response(conn, 200) =~ "New Comment"
    end

    test "redirects an unauthenticated visitor to log in", %{conn: conn} do
      post = post_fixture(user_id: user_fixture().id)

      conn = get(conn, ~p"/posts/#{post}/comments/new")

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "create" do
    test "creates a comment and redirects to the comments list", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/posts/#{post}/comments/new", comment: %{content: "Great post!"})

      assert redirected_to(conn) == ~p"/posts/#{post}/comments"
      assert [comment] = Comments.list_comments()
      assert comment.content == "Great post!"
      assert comment.user_id == user.id
      assert comment.post_id == post.id
    end

    test "re-renders the form with an error when the content is invalid", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/posts/#{post}/comments/new", comment: %{content: ""})

      assert html_response(conn, 200) =~ "can&#39;t be blank"
      assert Comments.list_comments() == []
    end

    test "notifies the post author when someone comments on their post", %{conn: conn} do
      author = user_fixture()
      commenter = user_fixture()
      post = post_fixture(user_id: author.id)

      conn
      |> log_in_user(commenter)
      |> post(~p"/posts/#{post}/comments/new", comment: %{content: "Nice work!"})

      assert [notification] = Blog.Notifications.get_unread_notifications(author.id)
      assert notification.actor_id == commenter.id
      assert notification.post_id == post.id
    end

    test "redirects an unauthenticated visitor to log in", %{conn: conn} do
      post = post_fixture(user_id: user_fixture().id)

      conn = post(conn, ~p"/posts/#{post}/comments/new", comment: %{content: "hi"})

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "edit" do
    test "renders the edit form pre-filled with the comment's content", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id, content: "Original text")

      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/comments/#{comment}/edit")

      response = html_response(conn, 200)
      assert response =~ "Edit Comment"
      assert response =~ "Original text"
    end
  end

  describe "update" do
    test "re-renders the form with an error when the new content is invalid", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit",
          comment: %{content: "", post_id: post.id}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
      assert Comments.get_comment!(comment.id).content == comment.content
    end

    test "succeeds even when the submitted params don't include post_id", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      # Regression test: this used to crash with a KeyError, since the
      # controller called Map.update!(comment_params, "post_id", ...), which
      # requires the key to already be present. The real form always
      # includes a hidden post_id field, so this never surfaced in the UI —
      # but any other client posting without it would have crashed.
      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit", comment: %{content: "no post_id here"})

      assert redirected_to(conn) == ~p"/posts/#{post}/comments/"
      assert Comments.get_comment!(comment.id).content == "no post_id here"
    end
  end

  describe "show" do
    test "lists a post's comments with their authors, publicly", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id, content: "First!")

      response = get(conn, ~p"/posts/#{post}/comments") |> html_response(200)

      assert response =~ comment.content
      assert response =~ user.email
    end

    test "shows an empty state when there are no comments", %{conn: conn} do
      post = post_fixture(user_id: user_fixture().id)

      response = get(conn, ~p"/posts/#{post}/comments") |> html_response(200)

      assert response =~ "No comments yet."
    end
  end
end
