defmodule LolBuddy.PlayerServer do
  use GenServer

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
    {:ok, []}
  end

  # Handle read calls
  # Returns {:reply, <value returned to client>, <state>}
  def handle_call({:read}, _from, list) do
    {:reply, list, list}
  end

  # Handle cast calls
  # Merely append the player to the list
  # Returns {:noreply, <state>
  def handle_cast({:add, player}, list) do
    {:noreply, [player | list]}
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  def add(pid, player) do
    GenServer.cast(pid, {:add, player})
  end
end
