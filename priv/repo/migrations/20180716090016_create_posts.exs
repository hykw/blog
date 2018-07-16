defmodule Blog.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:handle, :string)
      add(:content, :text)
      add(:published_at, :naive_datetime)
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all))
      timestamps()
    end

    create(unique_index(:posts, [:user_id, :handle]))
  end
end
