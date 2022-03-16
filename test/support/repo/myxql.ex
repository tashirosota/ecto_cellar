defmodule MyXQL.Repo do
  use Ecto.Repo,
    otp_app: :ecto_cellar,
    adapter: Ecto.Adapters.MyXQL

  def init(_, opts) do
    {:ok,
     Keyword.merge(opts,
       username: "root",
       password: "mysql-root",
       database: "ecto_cellar_mysql_test",
       hostname: "localhost",
       pool: Ecto.Adapters.SQL.Sandbox
     )}
  end
end
