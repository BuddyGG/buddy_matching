defmodule LolBuddyWeb.SummonerController do
  use LolBuddyWeb, :controller
  action_fallback CarExtractorWeb.FallbackController

  alias LolBuddy.RiotApi.Api

  @@doc """
  Get request to find a lol player via specified region and name
  """
  def show(conn, %{"region" => region, "name" => name}) do
    Api.fetch_summoner_info(name, String.to_atom(region))
    |> case do
        {:ok, summoner} -> render(conn, "show.json", summoner: summoner)
        {:error, error} -> render(conn, LolBuddyWeb.ErrorView, "error.json", error: error)
    end

  end
end
  
  
