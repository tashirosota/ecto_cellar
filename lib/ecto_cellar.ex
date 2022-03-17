defmodule EctoCellar do
  @moduledoc """
  Core module for EctoCellar.
  Handles versions table created by `mix ecto_cellar.gen`.
  You can use this module to store in the cellar and restore the version.
  For a model whose primary_key is other than `id`, specify `id_type` and use it.
  """

  alias EctoCellar.Version
  @native_datetime_prefix "ecto_cellar_native_datetime_"

  @doc """
  Stores the changes at that time in the cellar.
  """
  @spec store(struct(), atom()) :: {:ok, struct()} | {:error, struct()}
  def store(%mod{} = model, id_type \\ :id) do
    model_id = if id = Map.fetch!(model, id_type), do: to_string(id)

    case Version.create(%{
           model_name: mod |> inspect(),
           model_id: model_id,
           model_inserted_at: model.inserted_at,
           version: model |> cast_format_map |> Jason.encode!()
         }) do
      {:ok, _version} -> {:ok, model}
      error -> error
    end
  end

  @doc """
  Like store/2, except that if the record is invalid, raises an exception.
  """
  @spec store!(struct()) :: struct()
  def store!(%mod{} = model, id_type \\ :id) do
    model_id = if id = Map.fetch!(model, id_type), do: to_string(id)

    _version =
      Version.create!(%{
        model_name: mod |> inspect(),
        model_id: model_id,
        model_inserted_at: model.inserted_at,
        version: model |> cast_format_map |> Jason.encode!()
      })

    model
  end

  @doc """
  Returns a specific version of model from the cellar.
  """
  @spec one(struct(), NaiveDateTime.t(), any()) :: struct()
  def one(%mod{} = model, timestamp, id_type \\ :id) do
    Version.one(
      mod |> inspect(),
      timestamp,
      model |> Map.fetch!(id_type) |> to_string()
    )
    |> to_model(mod)
  end

  @doc """
  Returns all versions of model from the cellar.
  """
  @spec all(struct(), any()) :: list(struct())
  def all(%mod{} = model, id_type \\ :id) do
    Version.all(
      mod |> inspect(),
      model |> Map.fetch!(id_type) |> to_string()
    )
    |> to_models(mod)
  end

  defp to_models(versions, mod) do
    versions
    |> Enum.map(&to_model(&1, mod))
  end

  defp to_model(version, mod) do
    version =
      Jason.decode!(version.version)
      |> Enum.map(fn {key, value} ->
        {
          key |> String.to_existing_atom(),
          if(is_stored_native_datetime(value), do: restore_native_datetime(value), else: value)
        }
      end)

    struct(
      mod.__struct__,
      version
    )
  end

  defp cast_format_map(%{} = model) do
    model
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__])
    |> Enum.map(fn {key, value} ->
      {key, if(is_native_datetime(value), do: "#{@native_datetime_prefix}#{value}", else: value)}
    end)
    |> Map.new()
  end

  defp is_native_datetime(%NaiveDateTime{}), do: true
  defp is_native_datetime(_), do: false

  defp is_stored_native_datetime(datetime_str),
    do: to_string(datetime_str) =~ @native_datetime_prefix

  defp restore_native_datetime(datetime_str) do
    datetime_str
    |> String.replace(@native_datetime_prefix, "")
    |> NaiveDateTime.from_iso8601!()
  end
end
