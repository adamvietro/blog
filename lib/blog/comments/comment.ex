defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    belongs_to :post, Blog.Posts.Post, foreign_key: :post_id
    belongs_to :user, Blog.Accounts.User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_id, :user_id])
    |> validate_required([:content])
    |> validate_length(:content, max: 150)
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:user_id)
  end
end
