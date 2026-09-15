defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :date
    field :visibility, :boolean, default: false

    has_many :comments, Blog.Comments.Comment
    belongs_to :user, Blog.Accounts.User
    many_to_many :tags, Blog.Tags.Tag, join_through: "post_tags", on_replace: :delete
    # New for Notifications
    has_many :notifications, Blog.Notifications.Notification
    has_one :cover_image, Blog.Posts.CoverImage, on_replace: :update

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visibility, :user_id])
    |> cast_assoc(:cover_image)
    |> validate_required([:title, :content, :published_on, :visibility])
    |> unsafe_validate_unique(:title, Blog.Repo)
    |> unique_constraint(:title, message: "Unique titles only")
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end
