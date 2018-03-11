defmodule BuddyUmbrella.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps", start_permanent: Mix.env() == :prod, deps: deps()]
  end

  defp deps do
    [
      {:edeliver, "~> 1.4.3"},
      {:distillery, "~> 1.4"},
      {:conform, "~> 2.2"},
      {:pre_commit, "~> 0.2.4", only: :dev},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end
end
