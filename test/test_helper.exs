ExUnit.start()

if System.get_env("DB_ADAPTER") == "mysql" do
  MyXQL.Repo.start_link()
else
  Postgres.Repo.start_link()
end
