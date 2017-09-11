defmodule LolBuddyWeb.SummonerView do
  use LolBuddyWeb, :view
  alias LolBuddyWeb.SummonerView

  def render("show.json", %{summoner: summoner}) do
    %{data: render_one(summoner, SummonerView, "summoner.json")}
  end

  def render("summoner.json", %{summoner: summoner}) do
    summoner
  end

end
