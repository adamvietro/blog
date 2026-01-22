defmodule Blog.Notifications do
  @moduledoc """
  The Notification context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo
  alias Blog.Notifications.Notification

  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  def update_notification(%{user_id: user_id, post_id: post_id}) do
    notifications =
      from n in Notification,
        where:
          n.user_id == ^user_id and
            n.post_id ==
              ^post_id

    Repo.update_all(notifications, set: [read: true])
  end

  def get_notifications_by_user(user_id) do
    from(n in Notification,
      where: n.user_id == ^user_id,
      order_by: [desc: n.inserted_at],
      preload: [:post, :actor]
    )
    |> Repo.all()
  end

  def get_unread_notifications(user_id) do
    from(n in Notification,
      where: n.user_id == ^user_id and n.read == false,
      order_by: [desc: n.inserted_at],
      preload: [:post, :actor]
    )
    |> Repo.all()
  end

  def mark_as_read(notification_id, user_id) do
    from(n in Notification,
      where: n.id == ^notification_id and n.user_id == ^user_id
    )
    |> Repo.update_all(set: [read: true])
  end

  def mark_all_as_read(user_id) do
    from(n in Notification,
      where: n.user_id == ^user_id and n.read == false
    )
    |> Repo.update_all(set: [read: true])
  end

  def unread_count(user_id) do
    from(n in Notification,
      where: n.user_id == ^user_id and n.read == false,
      select: count(n.id)
    )
    |> Repo.one()
  end

  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
