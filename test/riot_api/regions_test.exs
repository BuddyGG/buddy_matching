defmodule LolBuddyRiotApi.RegionsTest do
  require LolBuddy.RiotApi.Regions
  use ExUnit.Case, async: true

  test ":br gets correct server:" do
    response = LolBuddy.RiotApi.Regions.endpoint(:br)
    assert response == "https://br1.api.riotgames.com"
  end

  test ":euw gets correct server:" do
    response = LolBuddy.RiotApi.Regions.endpoint(:euw)
    assert response == "https://euw1.api.riotgames.com"
  end

  test ":na gets correct server" do
    response = LolBuddy.RiotApi.Regions.endpoint(:na)
    assert response == "https://na1.api.riotgames.com"
  end

end

