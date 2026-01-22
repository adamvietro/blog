defmodule Blog.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :read, :boolean, default: false

    belongs_to :user, Blog.Accounts.User
    belongs_to :post, Blog.Posts.Post
    belongs_to :actor, Blog.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:post_id, :user_id, :actor_id, :read])
    |> validate_required([:post_id, :user_id, :actor_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:actor_id)
    |> unique_constraint([:user_id, :post_id], name: "notifications_user_id_post_id_index")
  end
end
