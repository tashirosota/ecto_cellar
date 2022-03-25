defmodule EctoCellar.Version do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @repo Application.compile_env!(:ecto_cellar, :repo)
  @required_fields ~w(model_name model_id model_inserted_at version)a

  schema "versions" do
    field(:model_id, :string)
    field(:model_name, :string)
    field(:model_inserted_at, :naive_datetime)
    field(:version, :string)
    timestamps()
  end

  @type version :: %__MODULE__{}

  @spec create(map()) :: {:ok, version} | {:error, term()}
  def create(attr) do
    %__MODULE__{}
    |> changeset(attr)
    |> @repo.insert
  end

  @spec create!(map()) :: {:ok, version}
  def create!(attr) do
    %__MODULE__{}
    |> changeset(attr)
    |> @repo.insert!
  end

  @spec all(String.t(), String.t()) :: list(version)
  def all(model_name, model_id) do
    __MODULE__
    |> where(model_name: ^model_name)
    |> where(model_id: ^model_id)
    |> @repo.all()
  end

  @spec one(String.t(), NaiveDateTime.t(), String.t()) :: version
  def one(model_name, model_inserted_at, model_id) do
    __MODULE__
    |> where(model_name: ^model_name)
    |> where(model_inserted_at: ^model_inserted_at)
    |> where(model_id: ^model_id)
    |> @repo.one()
  end

  defp changeset(model, params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:id, name: :PRIMARY)
  end
end
