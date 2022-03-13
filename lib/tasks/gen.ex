defmodule Mix.Tasks.EctoCellar.Gen do
  use Mix.Task
  @shortdoc "Generates a new migration for DynamoDB"

  def run(opts \\ []) do
    change = """
    create table(:versions) do
      add :model_name, :string, null: false
      add :model_id, :string, null: false
      add :version, :text, null: false
      timestamps()
    end
    create index(:versions, [:model_name, :module_id])
    """

    Mix.Tasks.Ecto.Gen.Migration.run(["create_version_tables", "-change #{change}"] + opts)
  end
end