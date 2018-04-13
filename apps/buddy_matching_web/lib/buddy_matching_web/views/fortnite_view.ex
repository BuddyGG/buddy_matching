defmodule BuddyMatchingWeb.FortniteView do
  use BuddyMatchingWeb, :view
  alias BuddyMatchingWeb.FortniteView

  def render("show.json", %{fortnite: stats}) do
    %{data: render_one(stats, FortniteView, "stats.json")}
  end

  def render("stats.json", %{fortnite: stats}) do
    stats
  end
end
