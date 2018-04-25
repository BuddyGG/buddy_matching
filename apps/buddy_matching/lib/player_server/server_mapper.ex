defmodule BuddyMatching.PlayerServer.ServerMapper do
  @moduledoc """
  The interface from which access to PlayerServers should be handled.
  Since players are stored in PlayerServers separated by server, this
  module unifies the access by mapping functions on PlayerServers to the correct
  PlayerServer, based on the given Player's server.
  """

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.PlayerServer

  @doc """
  Returns all players currently stored for the given server

  ## Examples
      iex> BuddyMatching.ServerMapper.get_players(:euw)
        [%{id: 1, name: "Lethly", server: :euw},
         %{id: 2, name: "hansp", server: :euw}]
  """
  def get_players(server) do
    server
    |> :global.whereis_name()
    |> PlayerServer.read()
  end

  @doc """
  Returns the amount of players in the given server

  ## Examples
      iex> BuddyMatching.ServerMapper.count_players(:euw)
      10
  """
  def count_players(server) do
    server
    |> :global.whereis_name()
    |> PlayerServer.count()
  end

  @doc """
  Adds the given player to a PlayerServer based
  on his server.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", server: :some_server}
      iex> BuddyMatching.ServerMapper.add_player(player)
        :ok
  """
  def add_player(%Player{server: server} = player) do
    server
    |> :global.whereis_name()
    |> PlayerServer.add(player)
  end

  @doc """
  Removes the given player from its server's PlayerServer

  ## Examples
      iex> player = %{id: 1, name: "Lethly", server: :non_existent_regoin}
      iex> BuddyMatching.ServerMapper.add_player(player)
        :ok
      iex> BuddyMatching.ServerMapper.remove_player(player)
        :ok
  """
  def remove_player(%Player{name: name, server: server} = player) do
    server
    |> :global.whereis_name()
    |> PlayerServer.remove(name)
  end

  @doc """
  Removes a player given their server and their name.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", server: :server}
      iex> BuddyMatching.ServerMapper.add_player(player)
        :ok
      iex> BuddyMatching.ServerMapper.remove_player("Lethly", :server)
        :ok
  """
  def remove_player(name, server) do
    server
    |> :global.whereis_name()
    |> PlayerServer.remove(name)
  end

  @doc """
  Updates the given player from its server's PlayerServer
  This will have no effect if the player isn't already in the PlayerServer.

  ## Examples
      iex> c1 = %Criteria{positions: [:marksman]}
      iex> player = %{id: 1, name: "Lethly", server: :server,
        criteria: c1}
      iex> BuddyMatching.ServerMapper.add(player)
        :ok
      iex> c2 = %Criteria{positions: [:jungle]}
      iex> player1 = %{player | criteria: c2}
      iex> BuddyMatching.ServerMapper.update(player1)
        :ok
  """
  def update_player(%Player{server: server} = player) do
    server
    |> :global.whereis_name()
    |> PlayerServer.update(player)
  end
end
