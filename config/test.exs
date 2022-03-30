import Config

if System.get_env("DB_ADAPTER") == "mysql" do
  config :ecto_cellar, :default_repo, MyXQL.Repo
  config :ecto_cellar, ecto_repos: [MyXQL.Repo]
else
  config :ecto_cellar, :default_repo, Postgres.Repo
  config :ecto_cellar, ecto_repos: [Postgres.Repo]
end
