defmodule Blog.Repo.Migrations.CreatePostTags do
  use Ecto.Migration

  def change do
      create table(:post_tags, primary_key: false ) do
        add :post_id, references(:posts, on_delete: :delete_all)
        add :tag_id, references(:tags, on_delete: :delete_all)
      end

      create(unique_index(:post_tags, [:post_id, :tag_id]))
  end
end
