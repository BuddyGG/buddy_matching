defmodule RiotApi.ApiMockTest do
  @moduledoc """
  Contains unpleasant but somewhat meaningful
  integration tests of RiotApi.

  We may consider refactoring all the datatypes that we encode
  with Poison to get the JSON of into .json files eventually.
  """

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
          "playerOrTeamName" => "Lethly",
          "queueType" => "RANKED_FLEX_SR",
          "rank" => "I",
          "tier" => "GOLD",
          "wins" => 23
        },
        %{
          "playerOrTeamName" => "Lethly",
          "queueType" => "RANKED_SOLO_5x5",
          "rank" => "I",
          "tier" => "GOLD",
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

  test "leagues with no rank finds rank from border" do
    name = "UghUgh"
    account_id = "account_id"
    tier = "GOLD"
    id = "id"
    match_id = 3_412_307_012

    leagues_response = Poison.encode!([])

    matches_response =
      Poison.encode!(%{
        "endIndex" => 1,
        "matches" => [
          %{
            "gameId" => match_id,
            "queue" => 420,
            "season" => 10
          }
        ],
        "startIndex" => 0,
        "totalGames" => 12
      })

    match_response =
      Poison.encode!(%{
        "gameId" => match_id,
        "participantIdentities" => [
          %{
            "participantId" => 1,
            "player" => %{
              "accountId" => 29_828_824,
              "currentAccountId" => 229_908_104,
              "summonerId" => 92_397_010,
              "summonerName" => "GG PREGNANT GG"
            }
          },
          %{
            "participantId" => 10,
            "player" => %{
              "accountId" => 24_332_475,
              "currentAccountId" => account_id,
              "summonerId" => 20_968_894,
              "summonerName" => name
            }
          }
        ],
        "participants" => [
          %{
            "championId" => 126,
            "highestAchievedSeasonTier" => "SILVER",
            "participantId" => 1
          },
          %{
            "championId" => 412,
            "highestAchievedSeasonTier" => tier,
            "participantId" => 10
          }
        ]
      })

    leagues_url =
      Regions.endpoint(:euw) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{@key}"

    matches_url =
      Regions.endpoint(:euw) <>
        "/lol/match/v3/matchlists/by-account/#{account_id}?queue=420&endIndex=1&api_key=#{@key}"

    match_url = Regions.endpoint(:euw) <> "/lol/match/v3/matches/#{match_id}?api_key=#{@key}"

    with_mock(
      HTTPoison,
      get: fn
        ^leagues_url -> success_response(leagues_response)
        ^matches_url -> success_response(matches_response)
        ^match_url -> success_response(match_response)
      end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: ^tier, rank: nil}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end

  test "leagues return unranked if cannot find league or border" do
    name = "UghUgh"
    account_id = "account_id"
    id = "id"
    match_id = 3_412_307_012

    leagues_response = Poison.encode!([])

    matches_response =
      Poison.encode!(%{
        "endIndex" => 1,
        "matches" => [
          %{
            "gameId" => match_id,
            "queue" => 420,
            "season" => 10
          }
        ],
        "startIndex" => 0,
        "totalGames" => 12
      })

    match_response =
      Poison.encode!(%{
        "gameId" => match_id,
        "participantIdentities" => [
          %{
            "participantId" => 10,
            "player" => %{
              "accountId" => 24_332_475,
              "currentAccountId" => account_id,
              "summonerId" => 20_968_894,
              "summonerName" => name
            }
          }
        ],
        "participants" => [
          %{
            "participantId" => 10
          }
        ]
      })

    leagues_url =
      Regions.endpoint(:euw) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{@key}"

    matches_url =
      Regions.endpoint(:euw) <>
        "/lol/match/v3/matchlists/by-account/#{account_id}?queue=420&endIndex=1&api_key=#{@key}"

    match_url = Regions.endpoint(:euw) <> "/lol/match/v3/matches/#{match_id}?api_key=#{@key}"

    with_mock(
      HTTPoison,
      get: fn
        ^leagues_url -> success_response(leagues_response)
        ^matches_url -> success_response(matches_response)
        ^match_url -> success_response(match_response)
      end
    ) do
      assert {:ok, %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: nil}} =
               RiotApi.leagues(id, account_id, :euw)
    end
  end

  test "test recent_roles_and_champions return expected result" do
    account_id = "account_id"

    response =
      Poison.encode!(%{
        "endIndex" => 20,
        "matches" => [
          %{
            "champion" => 96,
            "gameId" => 3_519_943_052,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_872_970_404
          },
          %{
            "champion" => 67,
            "gameId" => 3_519_875_372,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_871_086_573
          },
          %{
            "champion" => 18,
            "gameId" => 3_519_774_631,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_868_504_830
          },
          %{
            "champion" => 81,
            "gameId" => 3_514_813_204,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_518_514_148
          },
          %{
            "champion" => 67,
            "gameId" => 3_514_757_585,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_516_359_344
          },
          %{
            "champion" => 67,
            "gameId" => 3_512_457_989,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_335_834_667
          },
          %{
            "champion" => 119,
            "gameId" => 3_512_407_579,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_333_986_834
          },
          %{
            "champion" => 18,
            "gameId" => 3_512_218_275,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_327_289_385
          },
          %{
            "champion" => 81,
            "gameId" => 3_510_365_638,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_164_978_985
          },
          %{
            "champion" => 101,
            "gameId" => 3_510_334_190,
            "lane" => "MID",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "SOLO",
            "season" => 11,
            "timestamp" => 1_517_163_534_188
          },
          %{
            "champion" => 81,
            "gameId" => 3_509_035_691,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_087_854_736
          },
          %{
            "champion" => 67,
            "gameId" => 3_508_975_717,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_085_164_433
          },
          %{
            "champion" => 67,
            "gameId" => 3_508_932_343,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_083_116_545
          },
          %{
            "champion" => 8,
            "gameId" => 3_508_745_758,
            "lane" => "TOP",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "SOLO",
            "season" => 11,
            "timestamp" => 1_517_073_157_652
          },
          %{
            "champion" => 134,
            "gameId" => 3_508_687_278,
            "lane" => "MID",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "SOLO",
            "season" => 11,
            "timestamp" => 1_517_070_429_203
          },
          %{
            "champion" => 18,
            "gameId" => 3_508_638_736,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO",
            "season" => 11,
            "timestamp" => 1_517_068_971_445
          },
          %{
            "champion" => 126,
            "gameId" => 3_508_576_073,
            "lane" => "TOP",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "SOLO",
            "season" => 11,
            "timestamp" => 1_517_065_758_841
          },
          %{
            "champion" => 18,
            "gameId" => 3_508_519_747,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 420,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_063_335_028
          },
          %{
            "champion" => 53,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_SUPPORT",
            "season" => 11,
            "timestamp" => 1_517_007_436_196
          },
          %{
            "champion" => 96,
            "gameId" => 3_507_655_197,
            "lane" => "BOTTOM",
            "platformId" => "EUW1",
            "queue" => 440,
            "role" => "DUO_CARRY",
            "season" => 11,
            "timestamp" => 1_517_005_218_031
          }
        ],
        "startIndex" => 0,
        "totalGames" => 133
      })

    url =
      Regions.endpoint(:euw) <>
        "/lol/match/v3/matchlists/by-account/#{account_id}/recent?api_key=#{@key}"

    with_mock(
      HTTPoison,
      get: fn ^url -> success_response(response) end
    ) do
      assert {:ok, {["Vayne", "Tristana", "Ezreal"], [:marksman, :mid]}} =
               RiotApi.recent_champions_and_roles(account_id, :euw)
    end
  end
end
