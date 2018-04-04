defmodule BuddyMatchingWeb.SummonerView do
  use BuddyMatchingWeb, :view
  alias BuddyMatchingWeb.SummonerView

  def render("show.json", %{summoner: summoner}) do
    %{data: render_one(summoner, SummonerView, "summoner.json")}
  end

  def render("summoner.json", %{summoner: summoner}) do
    summoner
  end
end
