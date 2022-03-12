defmodule EctoNote.MixProject do
  use Mix.Project
  @source_url "https://github.com/tashirosota/ecto_note"
  @description "TODO:"

  def project do
    [
      app: :ecto_note,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: @description,
      name: "EctoNote",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
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
    ]
  end
end
