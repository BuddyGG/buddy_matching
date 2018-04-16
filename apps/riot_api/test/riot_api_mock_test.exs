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
end
