defmodule LolBuddy.RegionMapper do
  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer

  def lookup(server, region) do
    GenServer.call(server, {:lookup, region})
  end

  def get_players(region) do
    case lookup(PlayerServer, region) do
    {:ok, server} -> PlayerServer.read(server)
          _ -> nil
    end
  end

  def add_player(%Player{} = player) do
    case lookup(PlayerServer, player.region) do
    {:ok, server} -> PlayerServer.add(server, player)
          _ -> nil
    end
  end
end
