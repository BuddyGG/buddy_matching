defmodule BuddyMatching.PlayerServer.ServerMapper do
  @moduledoc """
  The interface from which access to PlayerServers should be accessed.
  Since players are stored in PlayerServers separated by server, this
  module unifies the access by mapping functions on PlayerServers to
  the correct PlayerServer, given a player to act on.
  """

  alias BuddyMatching.Players.Player
  alias BuddyMatching.PlayerServer
  alias BuddyMatching.PlayerServer.ServerExtractor

  # Utility method for finding a given Player's Server.
  defp server_from_player(%Player{} = player) do
    player
    |> ServerExtractor.server_from_player()
    |> :global.whereis_name()
  end

  @doc """
  Returns all players from the server associated with the given player

  ## Examples
    iex> player = %Player{game_info: %LolInfo{region: euw}}
    iex> BuddyMatching.ServerMapper.get_players(player)
    [%{id: 1, name: "Lethly", game_info: %LolInfo{region: :euw}},
     %{id: 2, name: "hansp", game_info: %LolInfo{region: :euw}}]
  """
  def get_players(%Player{} = player) do
    player
    |> server_from_player()
    |> PlayerServer.read()
  end

  @doc """
  Returns all players currently stored for the given server

  ## Examples
    iex> BuddyMatching.ServerMapper.get_players(:euw)
    [%{id: 1, name: "Lethly", game_info: %LolInfo{region: :euw}},
     %{id: 2, name: "hansp", game_info: %LolInfo{region: :euw}}]
  """
  def get_players(server) when is_atom(server) do
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
  def add_player(%Player{} = player) do
    player
    |> server_from_player()
    |> PlayerServer.add(player)
  end

  @doc """
  Removes the given player from its server's PlayerServer

  ## Examples
    iex> player = %{id: 1, name: "Lethly", game_info: %LolInfo{region: :euw}}
    iex> BuddyMatching.ServerMapper.add_player(player)
    :ok
    iex> BuddyMatching.ServerMapper.remove_player(player)
    :ok
  """
  def remove_player(%Player{name: name} = player) do
    player
    |> server_from_player
    |> PlayerServer.remove(name)
  end

  @doc """
  Removes a player given their server and their name.

  ## Examples
    iex> player = %{id: 1, name: "Lethly", game_info: %LolInfo{region: :euw}}
    iex> BuddyMatching.ServerMapper.add_player(player)
    :ok
    iex> BuddyMatching.ServerMapper.remove_player("Lethly", :euw)
    :ok
  """
  def remove_player(name, server) do
    server
    |> :global.whereis_name()
    |> PlayerServer.remove(name)
  end

  @doc """
  Updates the given player on its PlayerServer
  This will have no effect if the player isn't already in the PlayerServer.

  ## Examples
    iex> info = %LolInfo{region: euw, positions: [:marksman]}
    iex> player = %{id: 1, name: "Lethly", game_info: info}
    iex> BuddyMatching.ServerMapper.add(player)
    :ok
    iex> updated_info = %LolInfo{region: euw, positions: [:jungle]}
    iex> player1 = %{player | game_info: updated_info}
    iex> BuddyMatching.ServerMapper.update(player1)
    :ok
  """
  def update_player(%Player{} = player) do
    player
    |> server_from_player
    |> PlayerServer.update(player)
  end
end
