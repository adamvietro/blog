defmodule BlogWeb.NotificationControllerTest do
  use BlogWeb.ConnCase
  import Blog.AccountsFixtures
  import Blog.PostsFixtures

  alias Blog.Notifications

  # Helper to get flash messages from conn
  defp flash_message(conn, key) do
    Phoenix.Flash.get(conn.assigns.flash, key)
  end

  describe "index - as regular user" do
    setup [:create_user_with_notifications]

    test "lists all unread notifications for current user", %{
      conn: conn,
      user: user,
      notifications: _notifications
    } do
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/notifications")

      assert html_response(conn, 200) =~ "Notifications"
      assert html_response(conn, 200) =~ "Mark all as read"
    end

    test "shows empty state when no unread notifications", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/notifications")

      assert html_response(conn, 200) =~ "No unread notifications"
    end

    test "does not show other users' notifications", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      conn = log_in_user(conn, user)

      # Create notification for other user
      post = post_fixture(user_id: other_user.id)

      {:ok, _} =
        Notifications.create_notification(%{
          user_id: other_user.id,
          post_id: post.id,
          actor_id: user.id,
          read: false
        })

      conn = get(conn, ~p"/notifications")

      # Should not see other user's notifications
      notifications = conn.assigns.notifications
      assert Enum.all?(notifications, &(&1.user_id == user.id))
    end

    test "redirects to login when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/notifications")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "index - as admin" do
    setup [:create_admin_with_notifications]

    test "admin sees their own notifications, not all notifications", %{conn: conn, admin: admin} do
      conn = log_in_user(conn, admin)
      conn = get(conn, ~p"/notifications")

      notifications = conn.assigns.notifications
      assert Enum.all?(notifications, &(&1.user_id == admin.id))
    end
  end

  describe "mark_read - as regular user" do
    setup [:create_user_with_notifications]

    test "marks notification as read", %{
      conn: conn,
      user: user,
      notifications: [notification | _]
    } do
      conn = log_in_user(conn, user)
      conn = post(conn, ~p"/notifications/#{notification.id}/mark_read")

      assert redirected_to(conn) == ~p"/notifications"
      assert flash_message(conn, :info) == "Notification marked as read"

      # Verify it's marked as read
      updated = Blog.Repo.get(Blog.Notifications.Notification, notification.id)
      assert updated.read == true
    end

    test "cannot mark another user's notification as read", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      conn = log_in_user(conn, user)

      # Create notification for other user
      post = post_fixture(user_id: other_user.id)

      {:ok, other_notification} =
        Notifications.create_notification(%{
          user_id: other_user.id,
          post_id: post.id,
          actor_id: user.id,
          read: false
        })

      conn = post(conn, ~p"/notifications/#{other_notification.id}/mark_read")

      # Should still redirect but not mark as read
      assert redirected_to(conn) == ~p"/notifications"

      # Verify it's NOT marked as read
      updated = Blog.Repo.get(Blog.Notifications.Notification, other_notification.id)
      assert updated.read == false
    end

    test "redirects to login when not authenticated", %{
      conn: conn,
      notifications: [notification | _]
    } do
      conn = post(conn, ~p"/notifications/#{notification.id}/mark_read")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "mark_all_read - as regular user" do
    setup [:create_user_with_notifications]

    test "marks all notifications as read for current user", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      conn = post(conn, ~p"/notifications/mark_all_read")

      assert redirected_to(conn) == ~p"/notifications"
      assert flash_message(conn, :info) =~ "notifications marked as read"

      # Verify count is 0
      assert Notifications.unread_count(user.id) == 0
    end

    test "does not mark other users' notifications as read", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      conn = log_in_user(conn, user)

      # Create notification for other user
      post = post_fixture(user_id: other_user.id)

      {:ok, _} =
        Notifications.create_notification(%{
          user_id: other_user.id,
          post_id: post.id,
          actor_id: user.id,
          read: false
        })

      initial_count = Notifications.unread_count(other_user.id)

      _conn = post(conn, ~p"/notifications/mark_all_read")

      # Other user's count should be unchanged
      assert Notifications.unread_count(other_user.id) == initial_count
    end

    test "redirects to login when not authenticated", %{conn: conn} do
      conn = post(conn, ~p"/notifications/mark_all_read")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "mark_all_read - as admin" do
    setup [:create_admin_with_notifications]

    test "admin can only mark their own notifications as read", %{
      conn: conn,
      admin: admin,
      other_user: other_user
    } do
      conn = log_in_user(conn, admin)

      initial_other_count = Notifications.unread_count(other_user.id)

      _conn = post(conn, ~p"/notifications/mark_all_read")

      # Admin's notifications are marked
      assert Notifications.unread_count(admin.id) == 0

      # Other user's notifications are NOT marked
      assert Notifications.unread_count(other_user.id) == initial_other_count
    end
  end

  describe "notification badge count" do
    test "shows correct unread count for logged in user", %{conn: conn} do
      user = user_fixture()
      other_user = user_fixture()
      post1 = post_fixture(user_id: user.id)
      post2 = post_fixture(user_id: user.id)

      {:ok, _} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post1.id,
          actor_id: other_user.id,
          read: false
        })

      {:ok, _} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post2.id,
          actor_id: other_user.id,
          read: false
        })

      conn = log_in_user(conn, user)
      _conn = get(conn, ~p"/")

      # This would be tested in your layout, but the count should be available
      assert Notifications.unread_count(user.id) == 2
    end

    test "shows 0 when no unread notifications", %{conn: conn} do
      user = user_fixture()
      _conn = log_in_user(conn, user)

      assert Notifications.unread_count(user.id) == 0
    end
  end

  # Setup functions
  defp create_user_with_notifications(_) do
    user = user_fixture()
    other_user = user_fixture()
    post1 = post_fixture(user_id: user.id)
    post2 = post_fixture(user_id: user.id)

    {:ok, notif1} =
      Notifications.create_notification(%{
        user_id: user.id,
        post_id: post1.id,
        actor_id: other_user.id,
        read: false
      })

    {:ok, notif2} =
      Notifications.create_notification(%{
        user_id: user.id,
        post_id: post2.id,
        actor_id: other_user.id,
        read: false
      })

    %{user: user, other_user: other_user, notifications: [notif1, notif2]}
  end

  defp create_admin_with_notifications(_) do
    admin = admin_fixture()
    other_user = user_fixture()
    post1 = post_fixture(user_id: admin.id)
    post2 = post_fixture(user_id: admin.id)

    {:ok, notif1} =
      Notifications.create_notification(%{
        user_id: admin.id,
        post_id: post1.id,
        actor_id: other_user.id,
        read: false
      })

    {:ok, notif2} =
      Notifications.create_notification(%{
        user_id: admin.id,
        post_id: post2.id,
        actor_id: other_user.id,
        read: false
      })

    %{admin: admin, other_user: other_user, notifications: [notif1, notif2]}
  end
end
