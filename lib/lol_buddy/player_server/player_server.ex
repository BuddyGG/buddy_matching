defmodule LolBuddy.PlayerServer do
  alias LolBuddy.Players.Player
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
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
    {:noreply, list ++ [player]}
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  def add(pid, player) do
    GenServer.cast(pid, {:add, player})
  end

end
