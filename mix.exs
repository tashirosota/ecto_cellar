defmodule EctoCellar.MixProject do
  use Mix.Project
  @source_url "https://github.com/tashirosota/ecto_cellar"
  @description "Store changes to your models, for auditing or versioning."

  def project do
    [
      app: :ecto_cellar,
      version: "0.1.0",
      elixir: "~> 1.10",
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
      {:ecto_sql, "~> 3.0"},
      {:ecto, "~> 3.0"},
      {:jason, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:postgrex, "~> 0.15.0 or ~> 1.0", only: [:dev, :test], optional: true},
      {:myxql, "~> 0.4.0 or ~> 0.5.0", only: [:dev, :test], optional: true}
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support"]
  end

  defp elixirc_paths(_), do: ["lib"]
end
