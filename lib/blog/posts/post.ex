defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.DateValidator

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :date
    field :visibility, :boolean, default: false
    has_many :comments, Blog.Comments.Comment
    belongs_to :user, Blog.Accounts.User


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visibility, :user_id])
    |> validate_required([:title, :content, :published_on, :visibility])
    |> unsafe_validate_unique(:title, Blog.Repo)
    |> unique_constraint(:title)
    |> validate_date(:published_on, before: :utc_today, message: "Shouldn't be in the Future")
    |> foreign_key_constraint(:user_id)
  end
end
