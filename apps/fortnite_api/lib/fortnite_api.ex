defmodule FortniteApi do
  @moduledoc """
  This module handles all interaction with Fortnite's Unofficial API.
  It is expected to be accessed through 'FortniteApi.fetch_stats/2'.

  It is inspired by:
  https://github.com/qlaffont/fortnite-api
  """

  require OK
  alias FortniteApi.Stats
  alias FortniteApi.AccessServer
  alias Poison.Parser
  alias HTTPoison

  defp handle_json({:ok, %{status_code: 200, body: body}}), do: {:ok, Parser.parse!(body)}
  defp handle_json({_, %{status_code: _, body: body}}), do: {:error, body}

  defp fetch_account_id(username, access_token) do
    headers = AccessServer.get_headers_bearer(access_token)

    "https://persona-public-service-prod06.ol.epicgames.com/persona/api/public/account/lookup?q=#{
      username
    }"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  defp fetch_br_stats(account_id, access_token) do
    headers = AccessServer.get_headers_bearer(access_token)

    "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/stats/accountId/#{
      account_id
    }/bulk/window/alltime"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  @doc """
  Validates that the given platform is among the supported/expected
  platforms that the API currently supports.

  Returns an error tuple containing the lower case
  representation of the given platform assuming it is valid.

  ## Examples

    iex> FortniteApi.validate_platform("PC")
    {:ok, "pc"}
    iex> FortniteApi.validate_platform("GAMEBOY")
    {:error, "Bad paltform. Should be xb1/ps4/pc."}

  """
  def validate_platform(platform) do
    platform
    |> String.downcase()
    |> case do
      "xb1" -> {:ok, "xb1"}
      "ps4" -> {:ok, "ps4"}
      "pc" -> {:ok, "pc"}
      _ -> {:error, "Bad platform. Should be xb1/ps4/pc."}
    end
  end

  @doc """
  Returns a map containing the given player's
  stats for the given platform.

  ## Examples

    iex> FortniteApi.fetch_stats("Trollerenn", "PC")
    {:ok,
      %{"duo" => %{
       "gamesPlayed" => 5,
       "gamesWon" => 0,
       "killDeathRatio" => 1.2,
       "top1finishes" => 0,
       "top3finishes" => 0,
       "top5finishes" => 0
     },
     "platform" => "pc",
     "total" => %{"gamesPlayed" => 27, "gamesWon" => 1},
     "username" => "trollerenn"
    }}

  """
  def fetch_stats(name, platform) do
    OK.for do
      platform <- validate_platform(platform)
      access_token <- AccessServer.get_token()
      %{"id" => account_id, "displayName" => display_name} <- fetch_account_id(name, access_token)
      stats <- fetch_br_stats(account_id, access_token)
    after
      stats
      |> Stats.get_duo_stats(platform)
      |> Map.put("username", display_name)
      |> Map.put("platform", platform)
    end
  end
end
