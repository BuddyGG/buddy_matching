defmodule LolBuddy.PlayerServer.RegionMapper do
  @moduledoc """
  The interface from which access to PlayerServers should be handled.
  Since players are stored in PlayerServers separated by region, this
  module unifies the access by mapping functions on PlayerServers to the correct
  PlayerServer, based on the given Player's region.
  """

  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer

  @doc """
  Returns all players currently stored for the given region

  ## Examples
      iex> LolBuddy.RegionMapper.get_players(:euw)
        [%{id: 1, name: "Lethly", region: :euw},
         %{id: 2, name: "hansp", region: :euw}]
  """
  def get_players(region) do
    PlayerServer.read(region)
  end

  @doc """
  Adds the given player to a PlayerServer based
  on his region.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> LolBuddy.RegionMapper.add_player(player)
        :ok
  """
  def add_player(%Player{} = player) do
    PlayerServer.add(player.region, player)
  end

  @doc """
  Removes the given player from its region's PlayerServer

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> LolBuddy.RegionMapper.add_player(player)
        :ok
      iex> LolBuddy.RegionMapper.remove_player(player)
        :ok
  """
  def remove_player(%Player{} = player) do
    PlayerServer.remove(player.region, player)
  end

  @doc """
  Updates the given player from its region's PlayerServer
  This will have no effect if the player isn't already in the PlayerServer.

  ## Examples
      iex> c1 = %Criteria{positions: [:marksman]}
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_region,
        criteria: c1}
      iex> LolBuddy.RegionMapper.add(player)
        :ok
      iex> c2 = %Criteria{positions: [:jungle]}
      iex> player1 = %{player | criteria: c2}
      iex> LolBuddy.RegionMapper.update(player1)
        :ok
  """
  def update_player(%Player{} = player) do
    PlayerServer.update(player.region, player)
  end
end
