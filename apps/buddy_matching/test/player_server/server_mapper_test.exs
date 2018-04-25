defmodule BuddyMatching.PlayerServer.ServerMapperTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.PlayerServer
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Criteria.LolCriteria, as: Criteria

  setup do
    # Prepare two servers for our server mapper to use
    server1 = :server1
    server2 = :server2
    {:ok, _} = PlayerServer.start_link(name: {:global, server1})
    {:ok, _} = PlayerServer.start_link(name: {:global, server2})
    %{server1: server1, server2: server2}
  end

  test "player is added to server specific server", %{server1: server} do
    player = %Player{id: "1", name: "foo", server: server}
    ServerMapper.add_player(player)

    assert [^player] = ServerMapper.get_players(server)
  end

  test "player is not accessible from other servers", %{server1: server1, server2: server2} do
    player = %Player{id: "1", name: "foo", server: server1}
    ServerMapper.add_player(player)

    assert [] = ServerMapper.get_players(server2)
  end

  test "multiple players may be added to same server", %{server1: server} do
    player1 = %Player{id: "1", name: "bar", server: server}
    player2 = %Player{id: "2", name: "foo", server: server}
    ServerMapper.add_player(player1)
    ServerMapper.add_player(player2)

    assert 2 = length(ServerMapper.get_players(server))
  end

  test "players can be removed from server", %{server1: server} do
    player = %Player{id: "1", name: "foo", server: server}

    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    ServerMapper.remove_player(player)
    assert [] = ServerMapper.get_players(server)
  end

  test "players can be removed from server using name and server", %{server1: server} do
    player = %Player{id: "1", name: "foo", server: server}

    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    ServerMapper.remove_player(player.name, server)
    assert [] = ServerMapper.get_players(server)
  end

  test "remove_player removes correct player", %{server1: server} do
    player1 = %Player{id: "1", name: "foo", server: server}
    player2 = %Player{id: "2", name: "bar", server: server}

    ServerMapper.add_player(player1)
    ServerMapper.add_player(player2)
    assert 2 = length(ServerMapper.get_players(server))

    ServerMapper.remove_player(player2)
    assert [^player1] = ServerMapper.get_players(server)
  end

  test "update player updates player in server", %{server1: server} do
    assert ServerMapper.get_players(server) == []

    c1 = %Criteria{positions: [:marksman]}
    c2 = %Criteria{positions: [:jungle]}
    player = %Player{id: "0", name: "bar", criteria: c1, server: server}
    updated_player = %{player | criteria: c2}

    # player is added
    ServerMapper.add_player(player)
    assert [^player] = ServerMapper.get_players(server)

    # player is removed
    ServerMapper.update_player(updated_player)
    assert [^updated_player] = ServerMapper.get_players(server)
  end

  test "updating a player that isn't in server has no effect", %{server1: server} do
    assert ServerMapper.get_players(server) == []

    c1 = %Criteria{positions: [:marksman]}
    player = %Player{id: "0", name: "bar", criteria: c1, server: server}

    # player should not get added because not already present
    ServerMapper.update_player(player)
    assert [] = ServerMapper.get_players(server)
  end

  test "count counts the number of players on the server", %{server1: server} do
    assert ServerMapper.count_players(server) == 0

    # player is added
    player = %Player{id: "1", name: "foo", server: server}
    ServerMapper.add_player(player)

    assert ServerMapper.count_players(server) == 1
  end
end
