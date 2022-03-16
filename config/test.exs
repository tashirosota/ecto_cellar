import Config

if System.get_env("ECTO_ADAPTER") == "mysql" do
  config :ecto_cellar, :repo, MyXQL.Repo
  config :ecto_cellar, ecto_repos: [MyXQL.Repo]
else
  config :ecto_cellar, :repo, Postgres.Repo
  config :ecto_cellar, ecto_repos: [Postgres.Repo]
end
