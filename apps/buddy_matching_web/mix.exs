defmodule BuddyMatchingWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :buddy_matching_web,
      version: auto_version(),
      elixir: "~> 1.7",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def auto_version() do
    {rev, _} = System.cmd("git", ["rev-parse", "--short", "HEAD"], stderr_to_stdout: true)
    # HACK this is necessary for the command to result
    # in valid SemVer versions even during pre_commit hooks.
    if String.starts_with?(rev, "fatal") do
      "1.0.0"
    else
      "1.0.0+#{String.trim_trailing(rev)}"
    end
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BuddyMatchingWeb.Application, []},
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
      {:fortnite_api, in_umbrella: true},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 1.3"},
      {:ok, "~> 1.9"},
      {:uuid, "~> 1.1"},
    ]
  end
end
