defmodule Blog.NotificationsTest do
  use Blog.DataCase
  import Blog.AccountsFixtures
  import Blog.PostsFixtures

  alias Blog.Notifications
  alias Blog.Comments
  alias Blog.Repo

  describe "notifications" do
    test "create_notification/1 with valid data creates a notification" do
      post_author = user_fixture()
      commenter = user_fixture()
      post = post_fixture(user_id: post_author.id)

      attrs = %{
        user_id: post_author.id,
        post_id: post.id,
        actor_id: commenter.id,
        read: false
      }

      assert {:ok, notification} = Notifications.create_notification(attrs)
      assert notification.user_id == post_author.id
      assert notification.post_id == post.id
      assert notification.actor_id == commenter.id
      assert notification.read == false
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(%{})
    end

    test "get_unread_notifications/1 returns only unread notifications for user" do
      user = user_fixture()
      other_user = user_fixture()
      post1 = post_fixture(user_id: user.id)
      post2 = post_fixture(user_id: user.id)

      # Create unread notification
      {:ok, _unread} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post1.id,
          actor_id: other_user.id,
          read: false
        })

      # Create read notification
      {:ok, read_notif} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post2.id,
          actor_id: other_user.id,
          read: false
        })

      Notifications.mark_as_read(read_notif.id, user.id)

      notifications = Notifications.get_unread_notifications(user.id)

      assert length(notifications) == 1
      assert Enum.all?(notifications, &(&1.read == false))
      assert Enum.all?(notifications, &(&1.user_id == user.id))
    end

    test "mark_as_read/2 marks notification as read" do
      user = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: user.id)

      {:ok, notification} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post.id,
          actor_id: other_user.id,
          read: false
        })

      assert {1, _} = Notifications.mark_as_read(notification.id, user.id)

      updated = Repo.get(Notifications.Notification, notification.id)
      assert updated.read == true
    end

    test "mark_as_read/2 only marks notifications for the given user" do
      user1 = user_fixture()
      user2 = user_fixture()
      actor = user_fixture()
      post = post_fixture(user_id: user1.id)

      {:ok, notif1} =
        Notifications.create_notification(%{
          user_id: user1.id,
          post_id: post.id,
          actor_id: actor.id,
          read: false
        })

      {:ok, notif2} =
        Notifications.create_notification(%{
          user_id: user2.id,
          post_id: post.id,
          actor_id: actor.id,
          read: false
        })

      # User1 tries to mark their notification
      Notifications.mark_as_read(notif1.id, user1.id)

      # Verify only user1's notification is marked
      assert Repo.get(Notifications.Notification, notif1.id).read == true
      assert Repo.get(Notifications.Notification, notif2.id).read == false
    end

    test "mark_all_as_read/1 marks all unread notifications for user" do
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

      assert {2, _} = Notifications.mark_all_as_read(user.id)

      notifications = Notifications.get_unread_notifications(user.id)
      assert length(notifications) == 0
    end

    test "unread_count/1 returns correct count of unread notifications" do
      user = user_fixture()
      other_user = user_fixture()
      post1 = post_fixture(user_id: user.id)
      post2 = post_fixture(user_id: user.id)

      assert Notifications.unread_count(user.id) == 0

      {:ok, _} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post1.id,
          actor_id: other_user.id,
          read: false
        })

      assert Notifications.unread_count(user.id) == 1

      {:ok, notif2} =
        Notifications.create_notification(%{
          user_id: user.id,
          post_id: post2.id,
          actor_id: other_user.id,
          read: false
        })

      assert Notifications.unread_count(user.id) == 2

      Notifications.mark_as_read(notif2.id, user.id)

      assert Notifications.unread_count(user.id) == 1
    end

    test "notifications are created when comment is made on a post" do
      post_author = user_fixture()
      commenter = user_fixture()
      post = post_fixture(user_id: post_author.id)

      comment_attrs = %{
        content: "Great post!",
        post_id: post.id,
        user_id: commenter.id
      }

      {:ok, _comment} = Comments.create_comment(comment_attrs)

      notifications = Notifications.get_unread_notifications(post_author.id)
      assert length(notifications) == 1

      [notification] = notifications
      assert notification.user_id == post_author.id
      assert notification.post_id == post.id
      assert notification.actor_id == commenter.id
    end

    test "notification is not created when post author comments on their own post" do
      author = user_fixture()
      post = post_fixture(user_id: author.id)

      comment_attrs = %{
        content: "My own comment",
        post_id: post.id,
        user_id: author.id
      }

      {:ok, _comment} = Comments.create_comment(comment_attrs)

      notifications = Notifications.get_unread_notifications(author.id)
      assert length(notifications) == 0
    end

    test "all previous commenters get notified when new comment is made" do
      post_author = user_fixture()
      commenter1 = user_fixture()
      commenter2 = user_fixture()
      commenter3 = user_fixture()
      post = post_fixture(user_id: post_author.id)

      # First comment
      {:ok, _} =
        Comments.create_comment(%{
          content: "First comment",
          post_id: post.id,
          user_id: commenter1.id
        })

      # Second comment
      {:ok, _} =
        Comments.create_comment(%{
          content: "Second comment",
          post_id: post.id,
          user_id: commenter2.id
        })

      # Third comment - should notify author, commenter1, and commenter2
      {:ok, _} =
        Comments.create_comment(%{
          content: "Third comment",
          post_id: post.id,
          user_id: commenter3.id
        })

      # Check all got notified
      assert Notifications.unread_count(post_author.id) == 1
      assert Notifications.unread_count(commenter1.id) == 1
      assert Notifications.unread_count(commenter2.id) == 1
      # Don't notify yourself
      assert Notifications.unread_count(commenter3.id) == 0
    end

    test "existing unread notification is updated when new comment is made" do
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

      # Second comment - should update existing notification
      {:ok, _} =
        Comments.create_comment(%{
          content: "Second comment",
          post_id: post.id,
          user_id: commenter2.id
        })

      # Author should still only have 1 unread notification
      assert Notifications.unread_count(post_author.id) == 1

      # But the actor should be updated to commenter2
      [notification] = Notifications.get_unread_notifications(post_author.id)
      assert notification.actor_id == commenter2.id
    end
  end
end
