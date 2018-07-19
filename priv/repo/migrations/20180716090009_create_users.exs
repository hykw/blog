defmodule Blog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:email, :string)
      add(:hashed_password, :string)
      add(:active, :boolean)
      add(:access_token, :string)
      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:access_token]))
  end
end
