defmodule Postgres.Repo.Migrations.CreatePostComments do
  use Ecto.Migration

  def change do
    create table(:post_comments) do
      add :content, :string
      add :post_id, references(:posts)

      timestamps()
    end
  end
end
