defmodule RiotApi.ApiMockTest do
  @moduledoc """
  Contains integration tests for Riot's API.
  All related .json files are taking directly from Riot's API,
  with mere slight modifications to reduce the amount of hardcoded
  IDs needed.
  """

  alias RiotApi
  use ExUnit.Case, async: false

  import Mock

  # Sets up a bunch of hardcoded values, all of which align with the JSON
  # in the read .json files, all of which have been retrieved directly from Riot's API.
  setup_all do
    key = "API_KEY"
    region = :euw

    # Summoner info
    name = "Lethly"
    id = 22_267_137
    account_id = 26_102_926
    icon_id = 1407

    match_id = 3_412_307_012
    Application.put_env(:riot_api, :riot_api_key, key)

    summoner_url = RiotApi.format_url("/lol/summoner/v4/summoners/by-name/#{name}", region)

    matchlist_solo_url =
      RiotApi.format_url(
        "/lol/match/v4/matchlists/by-account/#{account_id}?queue=420&endIndex=20",
        region
      )

    matchlist_any_url =
      RiotApi.format_url("/lol/match/v4/matchlists/by-account/#{account_id}?endIndex=20", region)

    leagues_url = RiotApi.format_url("/lol/league/v4/positions/by-summoner/#{id}", region)

    solo_match_url =
      RiotApi.format_url(
        "/lol/match/v4/matchlists/by-account/#{account_id}?queue=420&endIndex=1",
        region
      )

    match_url = RiotApi.format_url("/lol/match/v4/matches/#{match_id}", region)

    summoner_json = File.read!("test/mock_json/summoner.json")
    matchlist_json = File.read!("test/mock_json/matchlist.json")
    short_matchlist_json = File.read!("test/mock_json/short_matchlist.json")
    leagues_json = File.read!("test/mock_json/leagues.json")
    leagues_unranked_json = File.read!("test/mock_json/leagues_unranked.json")
    solo_match_json = File.read!("test/mock_json/solo_match.json")
    match_json = File.read!("test/mock_json/match.json")
    match_unranked_json = File.read!("test/mock_json/match_unranked.json")

    [
      region: region,
      name: name,
      id: id,
      account_id: account_id,
      icon_id: icon_id,
      match_id: icon_id,
      summoner_url: summoner_url,
      matchlist_solo_url: matchlist_solo_url,
      matchlist_any_url: matchlist_any_url,
      leagues_url: leagues_url,
      solo_match_url: solo_match_url,
      match_url: match_url,
      summoner_json: summoner_json,
      matchlist_json: matchlist_json,
      short_matchlist_json: short_matchlist_json,
      leagues_json: leagues_json,
      leagues_unranked_json: leagues_unranked_json,
      solo_match_json: solo_match_json,
      match_json: match_json,
      match_unranked_json: match_unranked_json
    ]
  end

  defp success_response(value), do: {:ok, %{status_code: 200, body: value}}
  defp error_response(value), do: {:error, %{status_code: 404, body: value}}

  test "summoner_info returns correct tuple", context do
    name = context[:name]
    account_id = context[:account_id]
    id = context[:id]
    url = context[:summoner_url]
    region = context[:region]
    icon_id = context[:icon_id]
    response = context[:summoner_json]

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, {^name, ^id, ^account_id, ^icon_id}} = RiotApi.summoner_info(name, region)
    end
  end

  test "leagues returns correct tuple for placed players", context do
    id = context[:id]
    account_id = context[:account_id]
    url = context[:leagues_url]
    response = context[:leagues_json]

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end

  test "leagues with no rank finds rank from border", context do
    account_id = context[:account_id]
    id = context[:id]
    leagues_url = context[:leagues_url]
    solo_match_url = context[:solo_match_url]
    match_url = context[:match_url]

    leagues_response = context[:leagues_unranked_json]
    solo_match_response = context[:matchlist_json]
    match_response = context[:match_json]

    with_mock(
      HTTPoison,
      get: fn
        ^leagues_url -> success_response(leagues_response)
        ^solo_match_url -> success_response(solo_match_response)
        ^match_url -> success_response(match_response)
      end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: nil}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end

  test "leagues return unranked if cannot find league or border", context do
    id = context[:id]
    account_id = context[:account_id]
    leagues_url = context[:leagues_url]
    solo_match_url = context[:solo_match_url]
    match_url = context[:match_url]

    leagues_response = context[:leagues_unranked_json]
    solo_match_response = context[:solo_match_json]
    match_response = context[:match_unranked_json]

    with_mock(
      HTTPoison,
      get: fn
        ^leagues_url -> success_response(leagues_response)
        ^solo_match_url -> success_response(solo_match_response)
        ^match_url -> success_response(match_response)
      end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: nil}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end

  test "recent_roles_and_champions happy path integration test", context do
    account_id = context[:account_id]
    url = context[:matchlist_solo_url]
    region = context[:region]
    response = context[:matchlist_json]

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, {["Vayne", "Tristana", "Ezreal"], [:marksman, :mid]}} =
               RiotApi.recent_champions_and_roles(account_id, region)
    end
  end

  test "recent_roles_and_champions too few solo queue games integration test", context do
    account_id = context[:account_id]
    solo_url = context[:matchlist_solo_url]
    any_url = context[:matchlist_any_url]
    region = context[:region]
    solo_response = context[:short_matchlist_json]
    any_response = context[:matchlist_json]

    with_mock(
      HTTPoison,
      get: fn
        ^solo_url -> success_response(solo_response)
        ^any_url -> success_response(any_response)
      end
    ) do
      assert {:ok, {["Vayne", "Tristana", "Ezreal"], [:marksman, :mid]}} =
               RiotApi.recent_champions_and_roles(account_id, region)
    end
  end

  test "fetch_summoner_info integration test", context do
    name = context[:name]
    region = context[:region]

    summoner_url = context[:summoner_url]
    leagues_url = context[:leagues_url]
    matchlist_url = context[:matchlist_solo_url]

    summoner_response = context[:summoner_json]
    leagues_response = context[:leagues_json]
    matchlist_response = context[:matchlist_json]

    with_mock(
      HTTPoison,
      get: fn
        ^summoner_url -> success_response(summoner_response)
        ^leagues_url -> success_response(leagues_response)
        ^matchlist_url -> success_response(matchlist_response)
      end
    ) do
      assert {:ok,
              %{
                champions: ["Vayne", "Tristana", "Ezreal"],
                icon_id: 1407,
                leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
                name: "Lethly",
                positions: [:marksman, :mid],
                region: :euw
              }} = RiotApi.fetch_summoner_info(name, region)
    end
  end

  test "fetch_summoner_info fails if a single request fails", context do
    name = context[:name]
    region = context[:region]

    summoner_url = context[:summoner_url]
    leagues_url = context[:leagues_url]
    matchlist_url = context[:matchlist_solo_url]

    summoner_response = context[:summoner_json]
    leagues_response = context[:leagues_json]

    with_mock(
      HTTPoison,
      get: fn
        ^summoner_url -> success_response(summoner_response)
        ^leagues_url -> success_response(leagues_response)
        ^matchlist_url -> error_response("")
      end
    ) do
      assert {:error, _} = RiotApi.fetch_summoner_info(name, region)
    end
  end
end
