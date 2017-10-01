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

    player = %Player{}
    PlayerServer.add(server, player)
    assert [player] = PlayerServer.read(server)
  end

  test "players are added", %{server: server} do
    assert PlayerServer.read(server) == []

    player1 = %Player{id: 1}
    player2 = %Player{id: 2}
    PlayerServer.add(server, player1)
    assert [player1] = PlayerServer.read(server)

    PlayerServer.add(server, player2)
    assert length(PlayerServer.read(server)) == 2
  end

  @tag :pending
  test "players may not be added twice", %{server: server} do
    assert PlayerServer.read(server) == []
    player1 = %Player{id: 1}

    PlayerServer.add(server, player1)
    assert [player1] = PlayerServer.read(server)

    PlayerServer.add(server, player1)
    assert [player1] = PlayerServer.read(server)
  end

  test "player is removed", %{server: server} do
    assert PlayerServer.read(server) == []

    player = %Player{}
    #
    # player is added
    PlayerServer.add(server, player)
    assert [player] = PlayerServer.read(server)

    # player is removed
    PlayerServer.remove(server, player)
    assert [] = PlayerServer.read(server)
  end
end
