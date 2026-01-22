defmodule Blog.Repo.Migrations.AddInNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :actor_id, references(:users, on_delete: :delete_all), null: false

      add :read, :boolean, default: false, null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:post_id])
    create index(:notifications, [:user_id, :read])

    create unique_index(
             :notifications,
             [:user_id, :post_id],
             where: "read = false"
           )
  end
end
