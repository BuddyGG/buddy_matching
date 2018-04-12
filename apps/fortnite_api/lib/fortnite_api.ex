defmodule FortniteApi do
  @moduledoc """
  This module handles all interaction with Fortnite's Unofficial API.
  It is expected to be accessed through 'RiotApi.fetch_user_info/2'.
  """

  require OK
  alias FortniteApi.Stats
  alias FortniteApi.AccessServer
  alias Poison.Parser
  alias HTTPoison

  defp handle_json({:ok, %{status_code: 200, body: body}}), do: {:ok, Parser.parse!(body)}
  defp handle_json({_, %{status_code: _, body: body}}), do: {:error, body}
  defp get_headers_bearer(token), do: [{"Authorization", "bearer #{token}"}]

  defp fetch_account_id(username, access_token) do
    headers = get_headers_bearer(access_token)

    "https://persona-public-service-prod06.ol.epicgames.com/persona/api/public/account/lookup?q=#{
      username
    }"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  defp fetch_br_stats(account_id, access_token) do
    headers = get_headers_bearer(access_token)

    "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/stats/accountId/#{
      account_id
    }/bulk/window/alltime"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  def fetch_stats(username, platform) do
    OK.for do
      access_token <- AccessServer.get_token()
      account_info <- fetch_account_id(username, access_token)
      account_id <- Map.fetch(account_info, "id")
      display_name <- Map.fetch(account_info, "displayName")
      stats <- fetch_br_stats(account_id, access_token)
    after
      stats
      |> Stats.get_duo_stats(platform)
      |> Map.put("username", display_name)
      |> Map.put("platform", platform)
    end
  end
end
