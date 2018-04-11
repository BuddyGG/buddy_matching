defmodule BuddyMatchingWeb.StatsView do
  use BuddyMatchingWeb, :view
  alias BuddyMatchingWeb.StatsView

  def render("show.json", %{stats: stats}) do
    %{players_online: render_one(stats, StatsView, "players_online.json")}
  end

  def render("players_online.json", %{stats: stats}) do
    stats
  end
end
