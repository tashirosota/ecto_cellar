import Config

unless Mix.env() == :prod do
  import_config "#{config_env()}.exs"
end
