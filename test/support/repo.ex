defmodule Repo do
  use Ecto.Repo,
    otp_app: :ecto_cellar,
    adapter: Ecto.Adapters.Postgres
end