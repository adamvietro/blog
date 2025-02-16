defmodule Blog.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :text
      add :published_on, :date
      add :visibility, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
