defmodule EctoCellar do
  alias EctoCellar.Version

  @spec store(struct(), atom()) :: {:ok, struct()} | {:error, struct()}
  def store(%mod{} = model, id_type \\ :id) do
    case Version.create(%{
           model_name: mod |> inspect(),
           model_id: model |> Map.fetch!(id_type) |> inspect(),
           version: model |> Jason.encode!()
         }) do
      {:ok, _version} -> {:ok, model}
      error -> error
    end
  end

  @spec store!(struct()) :: struct()
  def store!(%mod{} = model, id_type \\ :id) do
    _version =
      Version.create!(%{
        model_name: mod |> inspect(),
        model_id: model |> Map.fetch!(id_type) |> inspect(),
        version: model |> Jason.encode!()
      })

    model
  end

  @spec one(struct(), integer(), any()) :: struct()
  def one(%mod{} = model, timestamp, id_type \\ :id) do
    Version.one(
      mod,
      timestamp,
      model |> Map.fetch!(id_type)
    )
    |> to_model(mod)
  end

  @spec all(struct(), any()) :: list(struct())
  def all(%mod{} = model, id_type \\ :id) do
    Version.all(
      mod,
      model |> Map.fetch!(id_type)
    )
    |> to_models(mod)
  end

  @spec to_models(list(Version.version()), atom()) :: list(struct())
  defp to_models(versions, mod) do
    versions
    |> Enum.map(&to_model(&1, mod))
  end

  @spec to_model(Version.version(), atom()) :: struct()
  defp to_model(version, mod) do
    struct(
      mod.__struct__,
      Jason.decode!(version.version)
    )
  end
end
