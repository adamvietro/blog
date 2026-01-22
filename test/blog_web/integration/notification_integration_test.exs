defmodule BlogWeb.NotificationIntegrationTest do
  use BlogWeb.ConnCase
  import Blog.AccountsFixtures
  import Blog.PostsFixtures

  alias Blog.Notifications
  alias Blog.Comments

  describe "full notification flow" do
    test "complete user journey: create post, receive comment, view notification, mark as read",
         %{conn: _conn} do
      # Setup: Create users
      post_author = user_fixture()
      commenter = user_fixture()

      # Post author creates a post
      post = post_fixture(user_id: post_author.id)

      # Commenter creates a comment (using the context directly instead of HTTP)
      {:ok, _comment} =
        Comments.create_comment(%{
          content: "Great post!",
          post_id: post.id,
          user_id: commenter.id
        })

      # Post author should have a notification
      assert Notifications.unread_count(post_author.id) == 1

      # Post author views notification page
      conn = build_conn()
      conn = log_in_user(conn, post_author)
      conn = get(conn, ~p"/notifications")

      assert html_response(conn, 200) =~ "Notifications"
      assert html_response(conn, 200) =~ commenter.email

      # Post author marks as read
      [notification] = Notifications.get_unread_notifications(post_author.id)
      conn = post(conn, ~p"/notifications/#{notification.id}/mark_read")

      assert redirected_to(conn) == ~p"/notifications"
      assert Notifications.unread_count(post_author.id) == 0
    end

    test "multiple commenters scenario: all get notified", %{conn: _conn} do
      # Setup
      post_author = user_fixture()
      commenter1 = user_fixture()
      commenter2 = user_fixture()
      commenter3 = user_fixture()

      post = post_fixture(user_id: post_author.id)

      # Commenter 1 comments
      {:ok, _} =
        Comments.create_comment(%{
          content: "First!",
          post_id: post.id,
          user_id: commenter1.id
        })

      # Post author should have 1 notification
      assert Notifications.unread_count(post_author.id) == 1
      assert Notifications.unread_count(commenter1.id) == 0

      # Commenter 2 comments
      {:ok, _} =
        Comments.create_comment(%{
          content: "Second!",
          post_id: post.id,
          user_id: commenter2.id
        })

      # Now post author and commenter1 should have notifications
      # Still 1, updated
      assert Notifications.unread_count(post_author.id) == 1
      # New
      assert Notifications.unread_count(commenter1.id) == 1
      assert Notifications.unread_count(commenter2.id) == 0

      # Commenter 3 comments
      {:ok, _} =
        Comments.create_comment(%{
          content: "Third!",
          post_id: post.id,
          user_id: commenter3.id
        })

      # Everyone except commenter3 should have notifications
      assert Notifications.unread_count(post_author.id) == 1
      assert Notifications.unread_count(commenter1.id) == 1
      assert Notifications.unread_count(commenter2.id) == 1
      assert Notifications.unread_count(commenter3.id) == 0

      # Log in as commenter1 and check they see the right notification
      conn = build_conn()
      conn = log_in_user(conn, commenter1)
      conn = get(conn, ~p"/notifications")

      response = html_response(conn, 200)
      assert response =~ "Notifications"
      # Latest commenter
      assert response =~ commenter3.email
    end

    test "post author commenting doesn't create self-notification", %{conn: _conn} do
      post_author = user_fixture()
      post = post_fixture(user_id: post_author.id)

      # Post author comments on their own post
      {:ok, _} =
        Comments.create_comment(%{
          content: "My own comment",
          post_id: post.id,
          user_id: post_author.id
        })

      # Should have no notifications
      assert Notifications.unread_count(post_author.id) == 0
    end

    test "notification updates when same post gets multiple comments", %{conn: _conn} do
      post_author = user_fixture()
      commenter1 = user_fixture()
      commenter2 = user_fixture()
      post = post_fixture(user_id: post_author.id)

      # First comment
      {:ok, _} =
        Comments.create_comment(%{
          content: "First comment",
          post_id: post.id,
          user_id: commenter1.id
        })

      [notif1] = Notifications.get_unread_notifications(post_author.id)
      assert notif1.actor_id == commenter1.id

      # Second comment - should UPDATE existing notification
      {:ok, _} =
        Comments.create_comment(%{
          content: "Second comment",
          post_id: post.id,
          user_id: commenter2.id
        })

      # Still only 1 notification, but actor should be updated
      notifications = Notifications.get_unread_notifications(post_author.id)
      assert length(notifications) == 1

      [updated_notif] = notifications
      # Same notification
      assert updated_notif.id == notif1.id
      # Updated actor
      assert updated_notif.actor_id == commenter2.id
    end

    test "admin user notifications work the same as regular users", %{conn: _conn} do
      admin = admin_fixture()
      regular_user = user_fixture()

      # Admin creates post
      admin_post = post_fixture(user_id: admin.id)

      # Regular user comments
      {:ok, _} =
        Comments.create_comment(%{
          content: "Comment on admin post",
          post_id: admin_post.id,
          user_id: regular_user.id
        })

      # Admin should get notification
      assert Notifications.unread_count(admin.id) == 1

      # Admin logs in and checks
      conn = build_conn()
      conn = log_in_user(conn, admin)
      conn = get(conn, ~p"/notifications")

      assert html_response(conn, 200) =~ "Notifications"
      assert html_response(conn, 200) =~ regular_user.email
    end

    test "mark all as read clears all notifications", %{conn: _conn} do
      user = user_fixture()
      commenter = user_fixture()

      # Create multiple posts and comments
      post1 = post_fixture(user_id: user.id)
      post2 = post_fixture(user_id: user.id)
      post3 = post_fixture(user_id: user.id)

      {:ok, _} =
        Comments.create_comment(%{
          content: "Comment 1",
          post_id: post1.id,
          user_id: commenter.id
        })

      {:ok, _} =
        Comments.create_comment(%{
          content: "Comment 2",
          post_id: post2.id,
          user_id: commenter.id
        })

      {:ok, _} =
        Comments.create_comment(%{
          content: "Comment 3",
          post_id: post3.id,
          user_id: commenter.id
        })

      # User should have 3 notifications
      assert Notifications.unread_count(user.id) == 3

      # Mark all as read
      conn = build_conn()
      conn = log_in_user(conn, user)
      conn = post(conn, ~p"/notifications/mark_all_read")

      assert redirected_to(conn) == ~p"/notifications"
      assert Notifications.unread_count(user.id) == 0
    end
  end
end
