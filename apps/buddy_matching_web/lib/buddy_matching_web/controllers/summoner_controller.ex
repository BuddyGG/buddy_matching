defmodule BuddyMatchingWeb.SummonerController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias RiotApi

  @doc """
  Get request to find a lol player via specified region and name
  """
  def show(conn, %{"region" => region, "name" => name}) do
    name
    |> RiotApi.fetch_summoner_info(String.to_existing_atom(region))
    |> case do
      {:ok, summoner} -> render(conn, "show.json", summoner: summoner)
      {:error, error} -> render(conn, BuddyMatchingWeb.ErrorView, "error.json", error: error)
    end
  end
end
