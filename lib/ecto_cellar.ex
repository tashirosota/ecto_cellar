defmodule EctoCellar do
  @moduledoc """
  Core module for EctoCellar.
  Handles versions table created by `mix ecto_cellar.gen`.
  You can use this module to store in the cellar and restore the version.
  For a model whose primary_key is other than `id`, specify `id_type` and use it.

  ## Options
   - repo:　You can select a repo other than the one specified in Config.
   - id_type: If the primary key is other than `id`, specify it.
  """

  alias EctoCellar.Version
  alias Ecto.Multi
  @native_datetime_prefix "ecto_cellar_native_datetime_"
  @type options :: Keyword.t()

  @doc """
  Stores the changes at that time in the cellar.
  """
  @spec store(Ecto.Schema.t() | Ecto.Changeset.t(), options) ::
          {:ok, Ecto.Schema.t()} | {:error, term()}
  def store(%mod{} = model, opts \\ []) do
    Version.create(
      %{
        model_name: mod |> inspect(),
        model_id: model_id(model, opts),
        model_inserted_at: model.inserted_at,
        version: model |> cast_format_map |> Jason.encode!()
      },
      repo(opts)
    )
    |> case do
      {:ok, _version} -> {:ok, model}
      error -> error
    end
  end

  @doc """
  Like store/2, except that if the record is invalid, raises an exception.
  """
  @spec store!(Ecto.Schema.t() | Ecto.Changeset.t(), options) :: Ecto.Schema.t()
  def store!(%mod{} = model, opts \\ []) do
    Version.create!(
      %{
        model_name: mod |> inspect(),
        model_id: model_id(model, opts),
        model_inserted_at: model.inserted_at,
        version: model |> cast_format_map |> Jason.encode!()
      },
      repo(opts)
    )

    model
  end

  @doc """
  Inserts given model（or changeset） and stores the changes at that time in the cellar.
   - options: EctoCellar.options()
   - insert_or_update_opts: options for Ecto.Repo.insert/2
  """
  @spec insert_and_store(Ecto.Schema.t() | Ecto.Changeset.t(), options, Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def insert_and_store(changeset, opts \\ [], insert_opts \\ []),
    do: do_wrap_func(changeset, opts, insert_opts, :insert)

  @doc """
  Updates given changeset and stores the changes at that time in the cellar.
   - options: EctoCellar.options()
   - insert_or_update_opts: options for Ecto.Repo.update/2
  """
  @spec update_and_store(Ecto.Changeset.t(), options, Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update_and_store(changeset, opts \\ [], update_opts \\ []),
    do: do_wrap_func(changeset, opts, update_opts, :update)

  @doc """
  Inserts or updates given changeset and stores the changes at that time in the cellar.
   - options: EctoCellar.options()
   - insert_or_update_opts: options for Ecto.Repo.insert_or_update/2
  """
  @spec insert_or_update_and_store(Ecto.Changeset.t(), options, Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def insert_or_update_and_store(changeset, opts \\ [], insert_or_update_opts \\ []),
    do: do_wrap_func(changeset, opts, insert_or_update_opts, :insert_or_update)

  defp do_wrap_func(changeset, celler_opts, ecto_opts, func_atom) do
    Multi.new()
    |> Multi.run(:schema, fn _repo, _ ->
      apply(repo(celler_opts), func_atom, [changeset, ecto_opts])
    end)
    |> Multi.run(:store, fn _repo, %{schema: schema} -> store(schema, celler_opts) end)
    |> repo(celler_opts).transaction()
    |> case do
      {:ok, %{schema: schema}} ->
        {:ok, schema}

      error ->
        error
    end
  end

  @doc """
  Returns a specific version of model from the cellar.
  """
  @spec one(struct(), NaiveDateTime.t(), options) :: Ecto.Schema.t()
  def one(%mod{} = model, timestamp, opts \\ []) do
    Version.one(
      mod |> inspect(),
      timestamp,
      model |> Map.fetch!(id_type(opts)) |> to_string(),
      repo(opts)
    )
    |> to_model(mod)
  end

  @doc """
  Returns all versions of model from the cellar.
  """
  @spec all(struct(), options) :: [Ecto.Schema.t()]
  def all(%mod{} = model, opts \\ []) do
    Version.all(
      mod |> inspect(),
      model |> Map.fetch!(id_type(opts)) |> to_string(),
      repo(opts)
    )
    |> to_models(mod)
  end

  @doc false
  def repo,
    do:
      Application.get_env(:ecto_cellar, :default_repo) || Application.get_env(:ecto_cellar, :repo)

  defp id_type(opts) when is_list(opts), do: opts[:id_type] || :id
  defp id_type(opts), do: opts

  defp repo(opts) when is_list(opts), do: opts[:repo] || EctoCellar.repo()
  defp repo(_), do: EctoCellar.repo()

  defp model_id(model, opts) do
    if id = Map.fetch!(model, id_type(opts)), do: to_string(id)
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

  defp cast_format_map(%{__meta__: %{schema: schema}} = model) do
    for field <- schema.__schema__(:fields),
        into: %{} do
      {field, maybe_encode_native_datetime(Map.get(model, field))}
    end
  end

  defp maybe_encode_native_datetime(%NaiveDateTime{} = value),
    do: "#{@native_datetime_prefix}#{value}"

  defp maybe_encode_native_datetime(value), do: value

  defp is_stored_native_datetime(datetime_str),
    do: to_string(datetime_str) =~ @native_datetime_prefix

  defp restore_native_datetime(datetime_str) do
    datetime_str
    |> String.replace(@native_datetime_prefix, "")
    |> NaiveDateTime.from_iso8601!()
  end
end
