defmodule BuddyMatching.PlayerServer.RegionMapperTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.PlayerServer
  alias BuddyMatching.PlayerServer.RegionMapper
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Criteria
  alias BuddyMatching.Players.LolInfo

  setup do
    # Prepare two servers for our region mapper to use
    region1 = :region1
    region2 = :region2
    {:ok, _} = PlayerServer.start_link(name: {:global, region1})
    {:ok, _} = PlayerServer.start_link(name: {:global, region2})
    %{region1: region1, region2: region2}
  end

  test "player is added to region specific server", %{region1: region} do
    player = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region}}
    RegionMapper.add_player(player)

    assert [^player] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "player is not accessible from other servers", %{region1: region1, region2: region2} do
    player = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region1}}
    RegionMapper.add_player(player)

    assert [] = RegionMapper.get_players(%LolInfo{region: region2})
  end

  test "multiple players may be added to same server", %{region1: region} do
    player1 = %Player{id: "1", name: "bar", game_info: %LolInfo{region: region}}
    player2 = %Player{id: "2", name: "foo", game_info: %LolInfo{region: region}}
    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)

    assert 2 = length(RegionMapper.get_players(%LolInfo{region: region}))
  end

  test "players can be removed from server", %{region1: region} do
    player = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region}}

    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(%LolInfo{region: region})

    RegionMapper.remove_player(player)
    assert [] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "players can be removed from server using name and region", %{region1: region} do
    player = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region}}

    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(%LolInfo{region: region})

    RegionMapper.remove_player(player.name, %LolInfo{region: region})
    assert [] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "remove_player removes correct player", %{region1: region} do
    player1 = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region}}
    player2 = %Player{id: "2", name: "bar", game_info: %LolInfo{region: region}}

    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)
    assert 2 = length(RegionMapper.get_players(%LolInfo{region: region}))

    RegionMapper.remove_player(player2)
    assert [^player1] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "update player updates player in server", %{region1: region} do
    assert RegionMapper.get_players(%LolInfo{region: region}) == []

    c1 = %Criteria{positions: [:marksman]}
    c2 = %Criteria{positions: [:jungle]}
    player = %Player{id: "0", name: "bar", criteria: c1, game_info: %LolInfo{region: region}}
    updated_player = %{player | criteria: c2}

    # player is added
    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(%LolInfo{region: region})

    # player is removed
    RegionMapper.update_player(updated_player)
    assert [^updated_player] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "updating a player that isn't in server has no effect", %{region1: region} do
    assert RegionMapper.get_players(%LolInfo{region: region}) == []

    c1 = %Criteria{positions: [:marksman]}
    player = %Player{id: "0", name: "bar", criteria: c1, game_info: %LolInfo{region: region}}

    # player should not get added because not already present
    RegionMapper.update_player(player)
    assert [] = RegionMapper.get_players(%LolInfo{region: region})
  end

  test "count counts the number of players on the server", %{region1: region} do
    assert RegionMapper.count_players(region) == 0

    # player is added
    player = %Player{id: "1", name: "foo", game_info: %LolInfo{region: region}}
    RegionMapper.add_player(player)

    assert RegionMapper.count_players(region) == 1
  end
end
