defmodule BuddyMatching.PlayerServer do
  @moduledoc """
  Simple GenServer for storing Players.
  Map used for data structure with name as key.
  Players for the given `server` are expected to be unique by their name.
  As such, the given game is expected to disallow duplicate names,
  at least for what corresponds to a `server` for that game..
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

  @doc """
  The PlayerServer's init function.
  Called automatically by `start_link`.
  Returns :ok and initial state of GenServer, which
  in this case is the empty map.
  """
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Synchronously handle read calls, in which we return
  all values from the map, meaning all Players.
  """
  def handle_call({:read}, _from, state) do
    {:reply, Map.values(state), state}
  end

  @doc """
  Synchronously handle count calls, in which
  the size of the current state is returning.
  """
  def handle_call({:count}, _from, state) do
    {:reply, map_size(state), state}
  end

  @doc """
  Synchronously handle add calls given a player.
  The player is added to state if was they were not already present in the state.
  Returns `:ok` if added, and `:error` if already in the state.
  """
  def handle_call({:add, player}, _from, state) do
    if Map.has_key?(state, player.name) do
      {:reply, :error, state}
    else
      {:reply, :ok, Map.put_new(state, player.name, player)}
    end
  end

  @doc """
  Synchronously handle remove calls given a key.
  If the given key exists in the state, the Player at the key is removed.
  Returns `{:ok, player}` if was present and is removed, otherwise returns `:error`.
  """
  def handle_call({:remove, key}, _from, state) do
    case Map.fetch(state, key) do
      {:ok, player} -> {:reply, {:ok, player}, Map.delete(state, key)}
      _ -> {:reply, :error, state}
    end
  end

  @doc """
  Synchronously handle update calls given a player.
  If a key is already present for the given player's key,
  the key is updated to point to the player given as parameter.
  Returns `:ok` if state was updated, otherwise returns `:error`.
  """
  def handle_call({:update, %Player{} = player}, _from, state) do
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
    [%Player{id: 1, name: "Lethly", game_info: %LolInfo{region: :euw}},
     %Player{id: 2, name: "Trolleren, game_info: %LolInfo{region: :euw}}]
  """
  def read(pid) do
    GenServer.call(pid, {:read})
  end

  @doc """
  Returns the number players on the specified server
  Method will run synchronously.
  ## Examples
    iex> BuddyMatching.PlayerServer.count(:euw)
    10
  """
  def count(pid) do
    GenServer.call(pid, {:count})
  end

  @doc """
  Adds the given player to the specified server
  Returns `:ok` if Player was not already in state..
  Otherwise returns `:error`.

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
  Returns `:ok` if player was in state, otherwise `:error`.
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
  Returns `{:ok, player}` if player was in state, otherwise `:error`.
  Method will run synchronously.

  ## Examples
    iex> BuddyMatching.PlayerServer.remove("Lethly")
    {:ok, %Player{id: 1, name: "Lethly"...}}
  """
  def remove(pid, name) do
    GenServer.call(pid, {:remove, name})
  end

  @doc """
  Updates the given player for the specified server, if the player
  already exists on the server.
  Returns `:ok` if player was in state and is updated,
  Otherwise returns `:error`.

  ## Examples
    iex> BuddyMatching.PlayerServer.update(%Player{name = "Lethly"})
    :ok
  """
  def update(pid, %Player{} = player) do
    GenServer.call(pid, {:update, player})
  end
end
