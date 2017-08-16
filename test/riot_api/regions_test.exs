defmodule LolBuddyRiotApi.RegionsTest do
  require LolBuddy.RiotApi.Regions
  use ExUnit.Case, async: true

  test ":br gets correct server:" do
    response = LolBuddy.RiotApi.Regions.endpoint(:br)
    assert response == "https://br.api.pvp.net"
  end

  test ":euw gets correct server:" do
    response = LolBuddy.RiotApi.Regions.endpoint(:euw)
    assert response == "https://euw.api.pvp.net"
  end

  test ":na gets correct server" do
    response = LolBuddy.RiotApi.Regions.endpoint(:na)
    assert response == "https://na.api.pvp.net"
  end

end

