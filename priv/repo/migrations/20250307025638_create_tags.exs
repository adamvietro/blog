defmodule Blog.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :string

      timestamps(type: :utc_datetime)
    end
  end
end
