defmodule LolBuddyWeb.SummonerView do
  use LolBuddyWeb, :view
  alias LolBuddyWeb.SummonerView

  def render("show.json", %{summoner: summoner}) do
    %{data: render_one(summoner, SummonerView, "summoner.json")}
  end

  def render("summoner.json", %{summoner: summoner}) do
    IO.inspect summoner.champions
    %{"name" => summoner.name,
      "region" => summoner.region,
      "champions" => render_many(summoner.champions, SummonerView, "champion.json" ),
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
