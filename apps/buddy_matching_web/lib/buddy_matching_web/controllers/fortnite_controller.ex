defmodule BuddyMatchingWeb.FortniteController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias FortniteApi

  @doc """
  Get request to stats for a fortnite player on a specific platform
  """
  def show(conn, %{"platform" => platform, "name" => name}) do
    name
    |> FortniteApi.fetch_stats(platform)
    |> case do
      {:ok, stats} -> render(conn, "show.json", fortnite: stats)
      {:error, error} -> render(conn, BuddyMatchingWeb.ErrorView, "error.json", error: error)
    end
  end
end
