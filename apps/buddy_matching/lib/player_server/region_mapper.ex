defmodule BuddyMatching.PlayerServer.RegionMapper do
  @moduledoc """
  The interface from which access to PlayerServers should be handled.
  Since players are stored in PlayerServers separated by region, this
  module unifies the access by mapping functions on PlayerServers to the correct
  PlayerServer, based on the given Player's region.
  """

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.FortniteInfo
  alias BuddyMatching.PlayerServer

  @doc """
  Returns all players currently stored for the given region

  ## Examples
      iex> BuddyMatching.RegionMapper.get_players(:euw)
        [%{id: 1, name: "Lethly", region: :euw},
         %{id: 2, name: "hansp", region: :euw}]
  """
  def get_players(%LolInfo{region: region}) do
    region
    |> :global.whereis_name()
    |> PlayerServer.read()
  end

  def get_players(%FortniteInfo{platform: platform}) do
    platform
    |> :global.whereis_name()
    |> PlayerServer.read()
  end

  @doc """
  Returns the amount of players in the given region

  ## Examples
      iex> BuddyMatching.RegionMapper.count_players(:euw)
      10
  """
  def count_players(region) do
    region
    |> :global.whereis_name()
    |> PlayerServer.count()
  end

  @doc """
  Adds the given player to a PlayerServer based
  on his region.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> BuddyMatching.RegionMapper.add_player(player)
        :ok
  """
  def add_player(%Player{game_info: %LolInfo{region: region}} = player) do
    region
    |> :global.whereis_name()
    |> PlayerServer.add(player)
  end

  def add_player(%Player{game_info: %FortniteInfo{platform: platform}} = player) do
    platform
    |> :global.whereis_name()
    |> PlayerServer.add(player)
  end

  @doc """
  Removes the given player from its region's PlayerServer

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> BuddyMatching.RegionMapper.add_player(player)
        :ok
      iex> BuddyMatching.RegionMapper.remove_player(player)
        :ok
  """
  def remove_player(%Player{game_info: %LolInfo{region: region}} = player) do
    region
    |> :global.whereis_name()
    |> PlayerServer.remove(player)
  end

  def remove_player(%Player{game_info: %FortniteInfo{platform: platform}} = player) do
    platform
    |> :global.whereis_name()
    |> PlayerServer.remove(player)
  end

  @doc """
  Removes a player given their region and their name.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :some_region}
      iex> BuddyMatching.RegionMapper.add_player(player)
        :ok
      iex> BuddyMatching.RegionMapper.remove_player("Lethly", :some_region)
        :ok
  """
  def remove_player(name, %LolInfo{region: region}) do
    region
    |> :global.whereis_name()
    |> PlayerServer.remove(name)
  end

  def remove_player(name, %FortniteInfo{platform: platform}) do
    platform
    |> :global.whereis_name()
    |> PlayerServer.remove(name)
  end

  @doc """
  Updates the given player from its region's PlayerServer
  This will have no effect if the player isn't already in the PlayerServer.

  ## Examples
      iex> c1 = %Criteria{positions: [:marksman]}
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_region,
        criteria: c1}
      iex> BuddyMatching.RegionMapper.add(player)
        :ok
      iex> c2 = %Criteria{positions: [:jungle]}
      iex> player1 = %{player | criteria: c2}
      iex> BuddyMatching.RegionMapper.update(player1)
        :ok
  """
  def update_player(%Player{game_info: %LolInfo{region: region}} = player) do
    region
    |> :global.whereis_name()
    |> PlayerServer.update(player)
  end

  def update_player(%Player{game_info: %FortniteInfo{platform: platform}} = player) do
    platform
    |> :global.whereis_name()
    |> PlayerServer.update(player)
  end
end
