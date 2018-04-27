defmodule BuddyMatching.PlayerServer.ServerExtractor do
  @moduledoc """
  Module for extracting a Player's Server information.
  In this context, server is the name of the PlayerServer
  that the given Player stored in.

  This is exposed in the form of server_from_player/1.
  """

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo

  def server_from_player(%Player{game_info: %FortniteInfo{} = info}) do
    info.platform
  end

  def server_from_player(%Player{game_info: %LolInfo{} = info}) do
    info.region
  end
end
