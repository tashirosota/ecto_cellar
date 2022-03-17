defmodule Postgres.Repo do
  use Ecto.Repo,
    otp_app: :ecto_cellar,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok,
     Keyword.merge(opts,
       username: "postgres",
       password: "postgres",
       database: "ecto_cellar_postgres_test",
       hostname: "localhost",
       pool: Ecto.Adapters.SQL.Sandbox,
       show_sensitive_data_on_connection_error: true,
       pool_size: 10
     )}
  end
end
