defmodule Mix.Tasks.EctoCellar.Gen do
  use Mix.Task
  @shortdoc "Generates a new migration file for EctoCellar"
  @repo Application.get_env(:ecto_cellar, :repo)

  def run(opts \\ []) do
    change = """

        create table(:versions) do
          add :model_id, :string, null: false
          add :model_name, :string, null: false
          add :model_inserted_at, :naive_datetime, null: false
          add :version, :text, null: false

          timestamps()
        end

        create index(:versions, [:model_name, :model_id])
    """

    Mix.Tasks.Ecto.Gen.Migration.run(
      ["-r", to_string(@repo), "create_version_tables", "--change", change] ++ opts
    )
  end
end
