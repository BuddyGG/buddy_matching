defmodule BuddyMatchingWeb.StatsController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias BuddyMatching.PlayerServer.RegionMapper

  @regions [:br, :eune, :euw, :jp, :kr, :lan, :las, :na, :oce, :tr, :ru, :pbe]

  @doc """
  Get request to get the amount of currently connected players
  """
  def show(conn, _param) do
    stats =
      Enum.reduce(@regions, %{}, fn x, acc -> Map.put(acc, x, RegionMapper.count_players(x)) end)

    render(conn, "show.json", stats: stats)
  end
end