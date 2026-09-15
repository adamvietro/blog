defmodule Blog.Analytics.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :path, :string
    field :visitor_hash, :string

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:path, :visitor_hash])
    |> validate_required([:path, :visitor_hash])
  end
end
