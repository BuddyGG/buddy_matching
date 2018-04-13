defmodule BuddyMatching.PlayerServer do
  @moduledoc """
  Simple GenServer for storing Players.
  Map used for data structure with name as key. Since PlayerServers
  are expected to be realm specific and without duplicates,
  this should disallow duplicates without conflicting keys.
  """
  use GenServer
  require Logger
  alias BuddyMatching.Players.Player

  @doc """
  Starts the PlayerServer with potential options.
  These are described here:
  https://hexdocs.pm/elixir/GenServer.html#start_link/3
  ## Examples
  iex> {:ok, pid} = BuddyMatching.PlayerServer.start_link
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # Called automatically by start_link
  # Returns :ok and initial state of GenServer
  def init(:ok) do
    {:ok, %{}}
  end

  # Handle calls with read - synchronous
  # Returns {:reply, <value returned to client>, <state>}
  def handle_call({:read}, _from, list) do
    {:reply, Map.values(list), list}
  end

  # Handle call with add - synchronous
  # Merely add the player into the Map. Return :ok, if Player
  # was added, otherwise return :error.
  # Returns {:noreply, <value returned to client>, <state>}
  def handle_call({:add, player}, _from, list) do
    if Map.has_key?(list, player.name) do
      {:reply, :error, list}
    else
      {:reply, :ok, Map.put_new(list, player.name, player)}
    end
  end

  # Handle call with remove - synchronous
  # Remove a player from the state given their name
  #
  # If Player was in state and was removed, returns
  # Returns {:reply, {:ok, player}, <updated_state>}
  #
  # If Player did not exist in state, returns:
  # Returns {:reply, :error, <state>}
  def handle_call({:remove, key}, _from, state) do
    case Map.fetch(state, key) do
      {:ok, player} -> {:reply, {:ok, player}, Map.delete(state, key)}
      _ -> {:reply, :error, state}
    end
  end

  # Handle call with update - synchronous
  # Updates a player from the state, hence expects at least
  # the key, to match a player in the state. - If the key does not exist,
  # nothing is done.
  #
  # If Player was in state returns:
  # Returns {:reply, :ok, <updated_state>}
  #
  # Otherwise if Player wasn't in state, returns:
  # Returns {:reply, :error, <state>}
  def handle_call({:update, player}, _from, state) do
    case Map.fetch(state, player.name) do
      {:ok, _} -> {:reply, :ok, Map.put(state, player.name, player)}
      _ -> {:reply, :error, state}
    end
  end

  # We ignore all other messages
  def handle_info(_, state) do
    {:noreply, state}
  end

  @doc """
  Returns the full list of players for the specified server
  Since this method uses GenServer.call it will be handled synchronously.
  #
  ## Examples
  iex> BuddyMatching.PlayerServer.read(:euw)
  [%{%Player{id: 1, name: "Lethly", region: :euw, voice: [false],
   languages: ["danish"], age_group: 1, positions: [:marksman],
   leagues: [diamond1], champions: ["Vayne", "Caitlyn", "Ezreal"],
   criteria: criteria, comment: "Fantastic player"}]
  """
  def read(pid) do
    GenServer.call(pid, {:read})
  end

  @doc """
  Adds the given player to the specified server
  Returns :ok if Player was not already in MapSet.
  Otherwise returns :error.
  Method will run synchronously.

  ## Examples
  iex> p1 = %Player{name: "Lethly"}
  iex> BuddyMatching.PlayerServer.add(p1)
  :ok
  iex> BuddyMatching.PlayerServer.add(p1)
  :error
  """
  def add(pid, player) do
    GenServer.call(pid, {:add, player})
  end

  @doc """
  Deletes the given player from the specified server
  Returns :ok if player was in state, otherwise :error.
  Method will run synchronously.

  ## Examples
  iex> BuddyMatching.PlayerServer.remove(%Player{name: "Lethly"})
  :ok
  """
  def remove(pid, %Player{name: name}) do
    GenServer.call(pid, {:remove, name})
  end

  @doc """
  Deletes the a player from the specified server, given their name.
  Returns :ok if player was in state, otherwise :error.
  Method will run synchronously.

  ## Examples
  iex> BuddyMatching.PlayerServer.remove("Lethly")
  :ok
  """
  def remove(pid, name) do
    GenServer.call(pid, {:remove, name})
  end

  @doc """
  Updates the given player from the specified server
  if he exists in the server's state. That is, if his key
  currently exists in the state.
  Returns :ok if player was in state and is updated,
  otherwise returns :error.
  Method will run synchronously.

  ## Examples
  iex> BuddyMatching.PlayerServer.update(%Player{name = "Lethly"})
  :ok
  """
  def update(pid, %Player{} = player) do
    GenServer.call(pid, {:update, player})
  end
end
