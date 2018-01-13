defmodule LolBuddy.PlayerServerTest do
  use ExUnit.Case, async: true
  alias LolBuddy.PlayerServer
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria

  setup do
    {:ok, server} = start_supervised PlayerServer
    %{server: server}
  end

  test "player is added", %{server: server} do
    assert PlayerServer.read(server) == []

    player = %Player{id: "1", name: "foo"}
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)
  end

  test "players are added", %{server: server} do
    assert PlayerServer.read(server) == []

    player1 = %Player{id: "1", name: "foo"}
    player2 = %Player{id: "2", name: "bar"}
    PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)

    PlayerServer.add(server, player2)
    assert length(PlayerServer.read(server)) == 2
  end

  test "players may not be added twice", %{server: server} do
    assert PlayerServer.read(server) == []
    player1 = %Player{id: "1", name: "foo"}

    PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)

    assert :error = PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)
  end

  test "player is removed", %{server: server} do
    assert PlayerServer.read(server) == []

    player = %Player{id: "1", name: "foo"}

    # player is added
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.remove(server, player)
    assert [] = PlayerServer.read(server)
  end

  test "absent player removal has no effect", %{server: server} do
    assert PlayerServer.read(server) == []

    absent_player = %Player{id: "0", name: "bar"}
    player = %Player{id: "1", name: "foo"}

    # player is added
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.remove(server, absent_player)
    assert [^player] = PlayerServer.read(server)
  end

  test "update player updates player", %{server: server} do
    assert PlayerServer.read(server) == []

    c1 = %Criteria{positions: [:marksman]}
    c2 = %Criteria{positions: [:jungle]}
    player = %Player{id: "0", name: "bar", criteria: c1}
    updated_player = %{player | criteria: c2}

    # player is added
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.update(server, updated_player)
    assert [^updated_player] = PlayerServer.read(server)
  end

  test "updating a player that isn't in server has no effect", %{server: server} do
    assert PlayerServer.read(server) == []

    c1 = %Criteria{positions: [:marksman]}
    player = %Player{id: "0", name: "bar", criteria: c1}

    # player should not get added because not already present
    PlayerServer.update(server, player)
    assert [] = PlayerServer.read(server)
  end
end
