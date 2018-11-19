defmodule Powerbot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :powerbot,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Powerbot.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_config, git: "https://github.com/djthread/ex_config.git"},
      {:tesla, "~> 1.2.0"},
      {:distillery, "~> 2.0"},
      {:toml, "~> 0.3.0"},
      {:jason, "~> 1.1"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: "credo --strict"
    ]
  end
end
