defmodule LolBuddyWeb.SummonerController do
    use LolBuddyWeb, :controller
    action_fallback CarExtractorWeb.FallbackController

    alias LolBuddy.RiotApi.Api

  def show(conn, %{"region" => region, "name" => name}) do
    Api.get_summoner_info(name, String.to_atom(region))
    |> case do
        {:ok, summoner} -> 
            IO.inspect summoner
            render(conn, "show.json", summoner: summoner)
        {:error, error} -> render(conn, LolBuddyWeb.ErrorView, "error.json", error: error)
    end

  end
end
  
  