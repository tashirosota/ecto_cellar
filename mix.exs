defmodule EctoCellar.MixProject do
  use Mix.Project
  @source_url "https://github.com/tashirosota/ecto_cellar"
  @description "TODO:"

  def project do
    [
      app: :ecto_cellar,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: @description,
      name: "EctoCellar",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Sota Tashiro"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:ecto, "~> 3.0"},
      {:jason, "~> 1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
