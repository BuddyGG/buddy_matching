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
end
