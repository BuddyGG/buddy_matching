defmodule BuddyMatchingWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :buddy_matching_web,
      version: "1.1.3",
      elixir: "~> 1.6",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BuddyMatching.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:riot_api, in_umbrella: true},
      {:buddy_matching, in_umbrella: true},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:cors_plug, "~> 1.3"},
      {:ok, "~> 1.9"},
      {:uuid, "~> 1.1"},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:pre_commit, "~> 0.2.4", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:edeliver, "~> 1.4.3"},
      {:distillery, "~> 1.4"},
      {:conform, "~> 2.2"}
    ]
  end
end
