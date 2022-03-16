defmodule Postgres.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :views, :integer

      timestamps()
    end
  end
end
