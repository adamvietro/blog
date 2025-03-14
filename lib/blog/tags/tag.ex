defmodule Blog.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    many_to_many :posts, Blog.Posts.Post, join_through: "post_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unsafe_validate_unique(:name, Blog.Repo)
    |> unique_constraint(:name)
  end
end
