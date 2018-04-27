defmodule BuddyMatching.PlayerServer.ServerMapperTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.PlayerServer
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatching.PlayerServer.ServerExtractor
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo

  setup do
    # Prepare two servers for our server mapper to use
    server1 = :server1
    server2 = :server2
    info1 = %LolInfo{region: server1}
    info2 = %LolInfo{region: server2}
    player1 = %Player{game_info: info1}
    player2 = %Player{game_info: info2}

    {:ok, _} = PlayerServer.start_link(name: {:global, server1})
    {:ok, _} = PlayerServer.start_link(name: {:global, server2})

    %{server1: server1, server2: server2, player1: player1, player2: player2}
  end

  test "player is added to server specific server", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    ServerMapper.add_player(player)

    assert [^player] = ServerMapper.get_players(server)
  end

  test "player is not accessible from other servers", %{player1: player, server2: other_server} do
    ServerMapper.add_player(player)
    assert [] = ServerMapper.get_players(other_server)
  end

  test "multiple players may be added to same server", %{player1: player1} do
    server = ServerExtractor.server_from_player(player1)
    player2 = %Player{player1 | name: "othername", id: "otherid"}
    ServerMapper.add_player(player1)
    ServerMapper.add_player(player2)

    assert 2 = length(ServerMapper.get_players(server))
  end

  test "players can be removed from server", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    ServerMapper.remove_player(player)
    assert [] = ServerMapper.get_players(server)
  end

  test "players can be removed from server using name and server", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    ServerMapper.remove_player(player.name, server)
    assert [] = ServerMapper.get_players(server)
  end

  test "remove_player removes correct player", %{player1: player1} do
    server = ServerExtractor.server_from_player(player1)
    player2 = %Player{player1 | name: "othername", id: "otherid"}

    ServerMapper.add_player(player1)
    ServerMapper.add_player(player2)
    assert 2 = length(ServerMapper.get_players(server))

    ServerMapper.remove_player(player2)
    assert [^player1] = ServerMapper.get_players(server)
  end

  test "update player updates player in server", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    assert ServerMapper.get_players(server) == []

    updated_player = put_in(player.game_info.positions, [:jungle])

    # player is added
    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    # player is updated
    ServerMapper.update_player(updated_player)
    assert [^updated_player] = ServerMapper.get_players(server)
  end

  test "updating a player that isn't in server has no effect", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    assert [] == ServerMapper.get_players(server)

    # player should not get added because not already present
    ServerMapper.update_player(player)
    assert [] = ServerMapper.get_players(server)
  end

  test "count_players/1 counts the number of players on the server", %{player1: player} do
    server = ServerExtractor.server_from_player(player)
    assert ServerMapper.count_players(server) == 0

    # player is added
    ServerMapper.add_player(player)
    assert ServerMapper.count_players(server) == 1
  end
end
