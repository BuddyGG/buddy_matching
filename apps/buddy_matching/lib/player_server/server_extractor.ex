defmodule BuddyMatching.PlayerServer.ServerExtractor do
  @moduledoc """
  Module for extracting a Player's Server information.
  In this context, server is the name of the PlayerServer
  that the given Player stored in.

  This is exposed in the form of `server_from_player/1`.
  """

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo

  @doc """
  Given a player with FortniteInfo `:game_info`, extract their server.
  In this case, this corresponds to their platform.

  ## Examples
    iex> player = %Player{name: "Lethly", id: 1, game_info: %FortniteInfo{platform: :xb1}}
    iex> ServerExtractor.server_from_player(player)
    :xb1
  """
  def server_from_player(%Player{game_info: %FortniteInfo{} = info}) do
    info.platform
  end

  @doc """
  Given a player with LolInfo `:game_info`, extract their server.
  In this case, this corresponds to their region.

  ## Examples
    iex> player = %Player{name: "Lethly", id: 1, game_info: %LolInfo{region: :euw}}
    iex> ServerExtractor.server_from_player(player)
    :euw
  """
  def server_from_player(%Player{game_info: %LolInfo{} = info}) do
    info.region
  end
end
