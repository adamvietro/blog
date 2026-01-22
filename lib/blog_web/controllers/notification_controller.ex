defmodule BlogWeb.NotificationController do
  use BlogWeb, :controller
  alias Blog.Notifications

  def index(conn, _params) do
    user_id = conn.assigns.current_user.id
    notifications = Notifications.get_unread_notifications(user_id)

    render(conn, :index, notifications: notifications)
  end

  def mark_read(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id
    Notifications.mark_as_read(id, user_id)

    conn
    |> put_flash(:info, "Notification marked as read")
    |> redirect(to: ~p"/notifications")
  end

  def mark_all_read(conn, _params) do
    user_id = conn.assigns.current_user.id
    {count, _} = Notifications.mark_all_as_read(user_id)

    conn
    |> put_flash(:info, "#{count} notifications marked as read")
    |> redirect(to: ~p"/notifications")
  end
end
