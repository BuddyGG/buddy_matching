defmodule LolBuddyWeb.SummonerView do
  use LolBuddyWeb, :view
  alias LolBuddyWeb.SummonerView

  def render("show.json", %{summoner: summoner}) do
    %{data: render_one(summoner, SummonerView, "summoner.json")}
  end

  def render("summoner.json", %{summoner: summoner}) do
    %{"name" => summoner.name,
      "region" => summoner.region,
      "champions" => summoner.champions,
      "leagues" => summoner.leagues,
      "positions" => summoner.positions
    }
  end

  def render("champion.json", %{summoner: champion}) do
    %{"name" => champion.name, 
      "id" => champion.id
    }
  end
  
end
