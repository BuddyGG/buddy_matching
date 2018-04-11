defmodule BuddyMatchingWeb.StatsController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias BuddyMatching.PlayerServer.RegionMapper

  @all_regions [:br, :eune, :euw, :jp, :kr, :lan, :las, :na, :oce, :tr, :ru, :pbe]

  @doc """
  Get request to get the amount of currently connected players
  """
  def show(conn, _param) do
    stats =
      @all_regions
      |> Enum.map(&{&1, RegionMapper.count_players(&1)})
      |> Enum.into(%{})

    render(conn, "show.json", stats: stats)
  end
end
