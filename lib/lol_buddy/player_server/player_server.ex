defmodule LolBuddy.PlayerServer do
  @moduledoc """
  Simple GenServer for storing Players.
  MapSet used for data structure, as a PlayerServer is
  expected to contain no duplicates.
  """
  use GenServer
  alias LolBuddy.Players.Player

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
    {:ok, MapSet.new}
  end

  # Handle calls with read - synchronous
  # Returns {:reply, <value returned to client>, <state>}
  def handle_call({:read}, _from, list) do
    {:reply, MapSet.to_list(list), list}
  end

  # Handle casts with remove - asynchronous
  # Remove a player from the state
  # Returns {:noreply, <state>}
  def handle_cast({:remove, player}, list) do
    {:noreply, MapSet.delete(list, player)}
  end

  # Handle casts with add - asynchronous
  # Merely add the player into the MapSet
  # Returns {:noreply, <state>}
  def handle_cast({:add, player}, list) do
    {:noreply, MapSet.put(list, player)}
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
  Always returns :ok if server exists.
  Method will run asynchronously.

  ## Examples
      iex> LolBuddy.PlayerServer.add(%Player{})
        :ok
  """
  #TODO fix so that a player can only be added once
  def add(pid, %Player{} = player) do
    GenServer.cast(pid, {:add, player})
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
end
