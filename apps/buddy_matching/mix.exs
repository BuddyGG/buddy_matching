defmodule BuddyMatching.Mixfile do
  use Mix.Project

  def project do
    [
      app: :buddy_matching,
      version: "1.2.0",
      elixir: "~> 1.6",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:gettext, "~> 0.11"},
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
