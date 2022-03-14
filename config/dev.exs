import Config

if System.get_env("ECTO_ADAPTER") == "mysql" do
  config :ecto_cellar, Repo.MyXQL,
    database: "ecto_cellar_mysql_dev",
    hostname: "localhost",
    password: "mysql-root",
    username: "root"

  config :ecto_cellar, :repo, Repo.MyXQL

  config :ecto_cellar, ecto_repos: [Repo.MyXQL]
else
  config :ecto_cellar, Repo.Postgres,
    database: "ecto_cellar_postgres_dev",
    hostname: "localhost",
    password: "postgres",
    username: "postgres"

  config :ecto_cellar, :repo, Repo.Postgres
  config :ecto_cellar, ecto_repos: [Repo.Postgres]
end
