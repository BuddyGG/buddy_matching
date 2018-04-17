defmodule RiotApi.ApiMockTest do
  alias RiotApi
  alias RiotApi.Regions
  use ExUnit.Case, async: false

  import Mock
  @key "API_KEY"

  setup_all do
    Application.put_env(:riot_api, :riot_api_key, @key)
  end

  defp success_response(value), do: {:ok, %{status_code: 200, body: value}}
  defp error_response(value), do: {:error, %{status_code: 404, body: value}}

  test "summoner_info returns correct tuple" do
    name = "Lethly"
    account_id = "account_id"
    id = "id"
    icon_id = "icon_id"

    response =
      Poison.encode!(%{
        "name" => name,
        "accountId" => account_id,
        "id" => id,
        "profileIconId" => icon_id
      })

    url = Regions.endpoint(:euw) <> "/lol/summoner/v3/summoners/by-name/#{name}?api_key=#{@key}"

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, {^name, ^id, ^account_id, ^icon_id}} = RiotApi.summoner_info("Lethly", :euw)
    end
  end

  test "leagues returns correct tuple for placed players" do
    account_id = "account_id"
    id = "id"

    response =
      Poison.encode!([
        %{
          "playerOrTeamId" => "22267137",
          "playerOrTeamName" => "Lethly",
          "queueType" => "RANKED_FLEX_SR",
          "rank" => "I",
          "tier" => "GOLD",
          "veteran" => false,
          "wins" => 23
        },
        %{
          "freshBlood" => false,
          "hotStreak" => false,
          "inactive" => false,
          "leagueId" => "3fe0b370-1eb3-11e8-9170-c81f66dd2a8f",
          "leagueName" => "Fiddlesticks's Elite",
          "leaguePoints" => 75,
          "losses" => 10,
          "playerOrTeamId" => "22267137",
          "playerOrTeamName" => "Lethly",
          "queueType" => "RANKED_SOLO_5x5",
          "rank" => "I",
          "tier" => "GOLD",
          "veteran" => false,
          "wins" => 10
        }
      ])

    url = Regions.endpoint(:euw) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{@key}"

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end
end
