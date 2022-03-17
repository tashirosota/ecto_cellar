defmodule Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :uuid, :string, primary_key: true, null: false
      add :title, :string
      add :views, :integer

      timestamps()
    end
  end
end
