defmodule Repo.MyXQL do
  use Ecto.Repo,
    otp_app: :ecto_cellar,
    adapter: Ecto.Adapters.MyXQL
end
