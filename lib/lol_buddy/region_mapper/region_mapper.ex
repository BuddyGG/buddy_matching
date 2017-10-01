defmodule LolBuddy.RegionMapper do
  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer

  def get_players(region) do
    PlayerServer.read(region)
  end

  def add_player(%Player{} = player) do
    PlayerServer.add(player.region, player)
  end
end
