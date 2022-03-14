import Config

unless Mix.env() == :prod do
  import_config "#{Mix.env()}.exs"
end
