ExUnit.start()

if System.get_env("DB_ADAPTER") == "mysql" do
  MyXQL.Repo.start_link()
else
  Application.ensure_all_started(:postgrex)
  Postgres.Repo.start_link()
end
