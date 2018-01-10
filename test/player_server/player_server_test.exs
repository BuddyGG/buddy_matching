defmodule LolBuddy.PlayerServerTest do
  use ExUnit.Case, async: true
  alias LolBuddy.PlayerServer
  alias LolBuddy.Players.Player

  setup do
    {:ok, server} = start_supervised PlayerServer
    %{server: server}
  end

  test "player is added", %{server: server} do
    assert PlayerServer.read(server) == []

    player = %Player{id: 1, name: "foo"}
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)
  end

  test "players are added", %{server: server} do
    assert PlayerServer.read(server) == []

    player1 = %Player{id: 1, name: "foo"}
    player2 = %Player{id: 2, name: "bar"}
    PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)

    PlayerServer.add(server, player2)
    assert length(PlayerServer.read(server)) == 2
  end

  test "players may not be added twice", %{server: server} do
    assert PlayerServer.read(server) == []
    player1 = %Player{id: 1, name: "foo"}

    PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)

    assert :error = PlayerServer.add(server, player1)
    assert [^player1] = PlayerServer.read(server)
  end

  test "player is removed", %{server: server} do
    assert PlayerServer.read(server) == []

    player = %Player{id: 1, name: "foo"}

    # player is added
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.remove(server, player)
    assert [] = PlayerServer.read(server)
  end

  test "absent player removal has no effect", %{server: server} do
    assert PlayerServer.read(server) == []

    absent_player = %Player{id: 0, name: "bar"}
    player = %Player{id: 1, name: "foo"}

    # player is added
    PlayerServer.add(server, player)
    assert [^player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.remove(server, absent_player)
    assert [^player] = PlayerServer.read(server)
  end
end
