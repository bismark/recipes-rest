defmodule Recipes.Mixfile do
  use Mix.Project

  def project do
    [app: :recipes,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
   ]
  end

  def application do
    [mod: {Recipes.Application, env(Mix.env)},
     extra_applications: [:logger, :runtime_tools]]
  end

  defp env(:test), do: [seed_store: false]
  defp env(_), do: [seed_store: true]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0-rc"},
      {:cowboy, "~> 1.0"},
      {:csv, "~> 1.4.2"},
      {:absinthe, "~> 1.3"},
      {:absinthe_plug, "~> 1.1"},
      {:dialyxir, "~> 0.5.0", only: :dev},
      {:excoveralls, "~> 0.6.3", only: :test},
    ]
  end
end
