<!-- @format -->

[![hex.pm version](https://img.shields.io/hexpm/v/ecto_cellar.svg)](https://hex.pm/packages/ecto_cellar)
[![CI](https://github.com/tashirosota/ecto_cellar/actions/workflows/ci.yml/badge.svg)](https://github.com/tashirosota/ecto_cellar/actions/workflows/ci.yml)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/tashirosota/ecto_cellar)

# EctoCellar

**Store changes to your models, for auditing or versioning.**
Inspired by [paper_trail](https://github.com/paper-trail-gem/paper_trail).

## Documentation

This is the user guide. See also, the [API reference](https://hexdocs.pm/ecto_cellar).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_cellar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_cellar, "~> 0.3"}
  ]
end
```

## Usage

### 1. Configuration.

Add ecto_cellar configure to your config.exs.

```elixir
config :ecto_cellar, :default_repo, YourApp.Repo
```

### 2. Creates versions table.

You can generate migration file for EctoCeller.
Let's type `mix ecto_cellar.gen`.
And migrate by `mix ecto.migrate`.

### 3. Stores changes to model.

Stores after a model is changed or created.
These are stored as recoverable versions for the versions table.

**By `Repo.insert` + `EctoCellar.store/2`.**

```elixir
iex> with {:ok, post} <- %Post{title: "title", views: 0} |> @repo.insert(),
...>      {:ok, _post} <- EctoCellar.store(post) do # or store!/2
...>   # do something
...> end
```

or

There is also a function that wraps `EctoRepo.insert`, `update` and `insert_or_update`.

**By `EctoCellar.insert_and_store/2`.**
（Uses `EctoCellar.update_and_store/2` when updated.）

```elixir
iex> case EctoCellar.insert_and_store(post) do # or store!/2
...>   {:ok, _post} -> # do_somesing
...>   error -> error
...> end
```

### 4. Gets versions and can restore it.

Uses `EctoCellar.all/2` and `EctoCellar.one/3`, you can get past changes versions.
And use it, you can restore.

```elixir
iex> post = Post.find(id)
%Post{id: 1, body: "body3"...etc}

iex> post_versions = EctoCellar.all(post) # Can get all versions.
[%Post{id: 1, body: "body3"...etc}, %Post{id: 1, body: "body2"...etc}, %Post{id: 1, body: "body1"...etc}]

iex> version_1_inserted_at = ~N[2022/12/12 12:00:12]
iex> post_version1 = EctoCellar.one(post, version_1_inserted_at)
%Post{id: 1, body: "body1", inserted_at: ~N[2022/12/12 12:00:12]...etc}

iex> post_version1
iex> |> Post.changeset([])
iex> |> Repo.update() # Restored！！！
```

### Options

**The last argument of each function accepts the following options.**

- repo: You can select a repo other than the one specified in Config.

## For contributers

You can test locally in these steps.

1. `make setup`
2. `mix test`

## Bugs and Feature requests

Feel free to open an issues or a PR to contribute to the project.
