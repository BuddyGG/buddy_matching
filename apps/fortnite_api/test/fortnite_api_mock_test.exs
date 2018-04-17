defmodule FortniteApi.MockTest do
  alias FortniteApi
  alias FortniteApi.AccessServer
  use ExUnit.Case, async: false

  import Mock

  @token "MOCK_TOKEN"
  @fortnite_stats [
    %{
      "name" => "br_score_pc_m0_p10",
      "ownerType" => 1,
      "value" => 703,
      "window" => "alltime"
    },
    %{
      "name" => "br_score_pc_m0_p9",
      "ownerType" => 1,
      "value" => 2669,
      "window" => "alltime"
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p10",
      "ownerType" => 1,
      "value" => 5,
      "window" => "alltime"
    },
    %{
      "name" => "br_score_pc_m0_p2",
      "ownerType" => 1,
      "value" => 678,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p2",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p9",
      "ownerType" => 1,
      "value" => 1_521_842_991,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1_521_834_802,
      "window" => "alltime"
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p2",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p9",
      "ownerType" => 1,
      "value" => 14,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop1_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p9",
      "ownerType" => 1,
      "value" => 20,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop12_pc_m0_p10",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p10",
      "ownerType" => 1,
      "value" => 1_521_986_670,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop10_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop25_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p10",
      "ownerType" => 1,
      "value" => 6,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop6_pc_m0_p9",
      "ownerType" => 1,
      "value" => 3,
      "window" => "alltime"
    }
  ]

  defp success_response(value), do: {:ok, %{status_code: 200, body: value}}
  defp error_response(value), do: {:error, %{status_code: 404, body: value}}

  defp account_id_url(username) do
    "https://persona-public-service-prod06.ol.epicgames.com/persona/api/public/account/lookup?q=#{
      username
    }"
  end

  defp br_stats_url(account_id) do
    "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/stats/accountId/#{
      account_id
    }/bulk/window/alltime"
  end

  test "fetch_stats with correct access returns expected stats" do
    headers = AccessServer.get_headers_bearer(@token)
    username = "trollerenn"
    platform = "pc"
    account_id = "123456789"
    account_id_url = account_id_url(username)
    stats_url = br_stats_url(account_id)

    id_response = Poison.encode!(%{"id" => account_id, "displayName" => username})
    stats_response = Poison.encode!(@fortnite_stats)

    expected_output =
      {:ok,
       %{
         "username" => username,
         "platform" => platform,
         "duo" => %{
           "gamesPlayed" => 5,
           "gamesWon" => 0,
           "killDeathRatio" => 1.2,
           "top1finishes" => 0,
           "top3finishes" => 0,
           "top5finishes" => 0
         },
         "total" => %{"totalGamesPlayed" => 27, "totalGamesWon" => 1}
       }}

    with_mocks([
      {HTTPoison, [],
       [
         get: fn
           ^account_id_url, ^headers -> success_response(id_response)
           ^stats_url, ^headers -> success_response(stats_response)
         end
       ]},
      {AccessServer, [:passthrough], [get_token: fn -> {:ok, @token} end]}
    ]) do
      assert expected_output == FortniteApi.fetch_stats(username, platform)
    end
  end

  test "fetch_stats with unsuccesful token requests returns error tuple" do
    error_message = "Failed to get token"

    with_mock(AccessServer, get_token: fn -> {:error, error_message} end) do
      assert {:error, ^error_message} = FortniteApi.fetch_stats("trollerenn", "pc")
    end
  end

  test "fetch_stats with unsuccesful web request returns error tuple" do
    headers = AccessServer.get_headers_bearer(@token)
    username = "trollerenn"
    platform = "pc"
    account_id = "123456789"
    account_id_url = account_id_url(username)
    stats_url = br_stats_url(account_id)

    id_response = Poison.encode!(%{"id" => account_id, "displayName" => username})

    with_mocks([
      {HTTPoison, [],
       [
         get: fn
           ^account_id_url, ^headers -> success_response(id_response)
           ^stats_url, ^headers -> error_response("Couldn't get stats")
         end
       ]},
      {AccessServer, [:passthrough], [get_token: fn -> {:ok, @token} end]}
    ]) do
      assert {:error, "Couldn't get stats"} = FortniteApi.fetch_stats(username, platform)
    end
  end
end
