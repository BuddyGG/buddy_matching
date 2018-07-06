defmodule FortniteApi.MockTest do
  alias FortniteApi
  alias FortniteApi.AccessServer
  use ExUnit.Case, async: false

  import Mock

  setup_all do
    token = "MOCK_TOKEN"
    username = "Ninja"
    platform = "PC"
    account_id = "123456789"
    account_id_json = File.read!("test/mock_json/account_id.json")
    stats_json = File.read!("test/mock_json/stats.json")

    account_id_url =
      "https://persona-public-service-prod06.ol.epicgames.com/persona/api/public/account/lookup?q=#{
        username
      }"

    stats_url =
      "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/stats/accountId/#{
        account_id
      }/bulk/window/alltime"

    [
      username: username,
      platform: platform,
      token: token,
      account_id: account_id,
      stats_json: stats_json,
      account_id_json: account_id_json,
      stats_url: stats_url,
      account_id_url: account_id_url
    ]
  end

  defp success_response(value), do: {:ok, %{status_code: 200, body: value}}
  defp error_response(value), do: {:error, %{status_code: 404, body: value}}

  test "fetch_stats with correct access returns expected stats", context do
    token = context[:token]
    headers = AccessServer.get_headers_bearer(token)
    username = context[:username]
    platform = context[:platform]
    account_id_url = context[:account_id_url]
    stats_url = context[:stats_url]
    stats_response = context[:stats_json]
    account_id_response = context[:account_id_json]

    expected_output =
      {:ok,
       %{
         "username" => "Ninja",
         "duo" => %{
           "gamesPlayed" => 2769,
           "gamesWon" => 1181,
           "killDeathRatio" => 12.675692695214106,
           "top5finishes" => 1386,
           "top12finishes" => 1626
         },
         "platform" => "pc",
         "total" => %{"totalGamesPlayed" => 6588, "totalGamesWon" => 2732},
         "solo" => %{
           "gamesPlayed" => 3458,
           "gamesWon" => 1190,
           "killDeathRatio" => 11.792768959435627,
           "top10finishes" => 1562,
           "top25finishes" => 1876
         },
         "squad" => %{
           "gamesPlayed" => 1613,
           "gamesWon" => 361,
           "killDeathRatio" => 8.093450479233226,
           "top3finishes" => 457,
           "top6finishes" => 553
         }
       }}

    with_mocks([
      {HTTPoison, [],
       [
         get: fn
           ^account_id_url, ^headers -> success_response(account_id_response)
           ^stats_url, ^headers -> success_response(stats_response)
         end
       ]},
      {AccessServer, [:passthrough], [get_token: fn -> {:ok, token} end]}
    ]) do
      assert expected_output == FortniteApi.fetch_stats(username, platform)
    end
  end

  test "fetch_stats with unsuccesful token requests returns error tuple", context do
    username = context[:username]
    platform = context[:platform]
    error_message = "Failed to get token"

    with_mock(AccessServer, get_token: fn -> {:error, error_message} end) do
      assert {:error, ^error_message} = FortniteApi.fetch_stats(username, platform)
    end
  end

  test "fetch_stats with unsuccesful web request returns error tuple", context do
    token = context[:token]
    headers = AccessServer.get_headers_bearer(token)
    username = context[:username]
    platform = context[:platform]
    account_id_url = context[:account_id_url]
    stats_url = context[:stats_url]
    account_id_response = context[:account_id_json]

    with_mocks([
      {HTTPoison, [],
       [
         get: fn
           ^account_id_url, ^headers -> success_response(account_id_response)
           ^stats_url, ^headers -> error_response("Couldn't get stats")
         end
       ]},
      {AccessServer, [:passthrough], [get_token: fn -> {:ok, token} end]}
    ]) do
      assert {:error, "Couldn't get stats"} = FortniteApi.fetch_stats(username, platform)
    end
  end
end
