defmodule Blog.Repo.Migrations.CommentsAddUserIdColumn do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
