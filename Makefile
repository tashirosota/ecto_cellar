up:
	docker-compose up

down:
	docker-compose down

setup:
	MIX_ENV=test mix ecto.create && MIX_ENV=test mix ecto.migrate

setup_mysql:
	MIX_ENV=test DB_ADAPTER=mysql mix ecto.create && MIX_ENV=test DB_ADAPTER=mysql mix ecto.migrate