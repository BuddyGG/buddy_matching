defmodule BuddyUmbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/BuddyGG/buddy_matching",
      name: "Buddy Matching",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  defp deps do
    [
      {:edeliver, "~> 1.6"},
      {:distillery, "~> 2.1", warn_missing: false},
      {:pre_commit, "~> 0.2.4", only: [:dev, :test]},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end
end
