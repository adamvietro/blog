defmodule Blog.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :path, :string, null: false
      add :visitor_hash, :string, null: false

      timestamps(updated_at: false, type: :utc_datetime)
    end

    create index(:visits, [:inserted_at])
    create index(:visits, [:visitor_hash])
  end
end
