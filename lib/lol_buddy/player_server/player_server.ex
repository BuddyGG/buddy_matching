defmodule LolBuddy.PlayerServer do
  @moduledoc """
  Simple GenServer for storing Players.
  Map used for data structure with name as key. Since PlayerServers
  are expected to be realm specific and without duplicates,
  this should disallow duplicates without conflicting keys.
  """
  use GenServer
  require Logger
  alias LolBuddy.Players
  alias LolBuddy.Players.Player
  alias LolBuddyWeb.Endpoint
  alias Phoenix.Socket.Broadcast

  @unmatch_event "remove_player"

  @doc """
  Starts the PlayerServer.
  ## Examples
  iex> {:ok, pid} = LolBuddy.PlayerServer.start_link
  {:ok, #PID<0.246.0>}
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  This specific initializer is used by ExUnit.

  Starts the PlayerServer with potential options.
  These are described here:
  https://hexdocs.pm/elixir/GenServer.html#start_link/3
  ## Examples
  iex> {:ok, pid} = LolBuddy.PlayerServer.start_link
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
      :ok = Endpoint.subscribe("players:" <> player.id, [])
      {:reply, :ok, Map.put_new(list, player.name, player)}
    end
  end

  # Handle casts with remove - asynchronous
  # Remove a player from the state
  # Returns {:noreply, <state>}
  def handle_cast({:remove, player}, list) do
    {:noreply, Map.delete(list, player.name)}
  end

  # Handle casts with update - asynchronous
  # Updates a player from the state, hence expects at least
  # the key, to match a player in the state. - If the key does not exist,
  # nothing is done.
  # Returns {:noreply, <state>}
  def handle_cast({:update, player}, state) do
    case Map.fetch(state, player.name) do
      {:ok, _} -> {:noreply, Map.put(state, player.name, player)}
      _ -> {:noreply, state}
    end
  end

  # When we get a 'presence_diff' with no leaves, we do nothing.
  def handle_info(%Broadcast{event: "presence_diff", payload: %{leaves: %{} = leaves}}, state)
      when leaves == %{} do
    {:noreply, state}
  end

  # When a player leaves the channel, we unsubscribe to his topic,
  # remove him from the state. In a separate process alert all the matches
  # he may have had, that he has left.
  def handle_info(%Broadcast{event: "presence_diff", payload: %{leaves: leaves}}, state) do
    [name | _] =
      leaves
      |> Map.values()
      |> Enum.map(fn %{metas: [%{name: name}]} -> name end)

    Task.start(fn ->
      [topic | _] = Map.keys(leaves)
      Endpoint.unsubscribe("players:" <> topic)

      if Map.has_key?(state, name) do
        player = state[name]

        player
        |> Players.get_matches(Map.values(state))
        |> Enum.each(fn match ->
          Logger.debug(fn -> "Broadcast remove player to #{match.id}: #{inspect(player)}" end)
          Endpoint.broadcast!("players:#{match.id}", @unmatch_event, player)
        end)
      end
    end)

    {:noreply, Map.delete(state, name)}
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
  iex> LolBuddy.PlayerServer.read(:euw)
  [%{%Player{id: 1, name: "Lethly", region: :euw, voice: false,
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
  iex> p1 = %Player{}
  iex> LolBuddy.PlayerServer.add(p1)
  :ok
  iex> LolBuddy.PlayerServer.add(p1)
  :error
  """
  def add(pid, player) do
    GenServer.call(pid, {:add, player})
  end

  @doc """
  Deletes the given player from the specified server
  Always returns :ok if server exists.
  Method will run asynchronously.

  ## Examples
  iex> LolBuddy.PlayerServer.remove(%Player{})
  :ok
  """
  def remove(pid, %Player{} = player) do
    GenServer.cast(pid, {:remove, player})
  end

  @doc """
  Updates the given player from the specified server
  if he exists in the server's state. That is, if his key
  currently exists in the state.
  Always returns :ok if server exists.
  Method will run asynchronously.

  ## Examples
  iex> LolBuddy.PlayerServer.update(%Player{name = "Lethly"})
  :ok
  """
  def update(pid, %Player{} = player) do
    GenServer.cast(pid, {:update, player})
  end
end
