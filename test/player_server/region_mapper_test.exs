defmodule LolBuddy.PlayerServer.RegionMapperTest do
  use ExUnit.Case, async: true
  alias LolBuddy.PlayerServer
  alias LolBuddy.PlayerServer.RegionMapper
  alias LolBuddy.Players.Player

  setup do
    # Prepare two servers for our region mapper to use
    region1 = :region1
    region2 = :region2
    {:ok, _} = PlayerServer.start_link(name: region1)
    {:ok, _} = PlayerServer.start_link(name: region2)
    %{region1: region1, region2: region2}
  end

  test "player is added to region specific server", %{region1: region} do
    player = %Player{id: 1, name: "foo", region: region}
    RegionMapper.add_player(player)

    assert [^player] = RegionMapper.get_players(player.region)
  end

  test "player is not accessible from other servers", %{region1: region1, region2: region2} do
    player = %Player{id: 1, name: "foo", region: region1}
    RegionMapper.add_player(player)

    assert [] = RegionMapper.get_players(region2)
  end

  test "multiple players may be added to same server", %{region1: region} do
    player1 = %Player{id: 1, name: "bar", region: region}
    player2 = %Player{id: 2, name: "foo", region: region}
    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)

    assert 2 = length(RegionMapper.get_players(region))
  end

  test "players can be removed from server", %{region1: region} do
    player = %Player{id: 1, name: "foo", region: region}

    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(player.region)

    RegionMapper.remove_player(player)
    assert [] = RegionMapper.get_players(player.region)
  end

  test "remove_player removes correct player", %{region1: region} do
    player1 = %Player{id: 1, name: "foo", region: region}
    player2 = %Player{id: 2, name: "bar", region: region}

    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)
    assert 2 = length(RegionMapper.get_players(region))

    RegionMapper.remove_player(player2)
    assert [^player1] = RegionMapper.get_players(region)
  end
end
