defmodule BuddyMatchingWeb.Presence.LeaveTracker do
  @moduledoc """
  Simple GenServer for handling Phoenix Presence,
  and keeping track of Player's leaving, for which it will ensure
  that they are removed from their related PlayerServer.
  """
  use GenServer
  require Logger
  alias BuddyMatching.Players
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatchingWeb.Endpoint
  alias BuddyMatchingWeb.PlayersChannel
  alias Phoenix.Socket.Broadcast

  @doc """
  Starts the LeaveTracker as a singleton registered
  with the name of the module.

  ## Examples
  iex> {:ok, pid} = BuddyMatching.LeaveTracker.start_link
  {:ok, #PID<0.246.0>}

  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  The LeaveTracker's init function.
  Called automatically by `start_link`.
  Returns :ok and initial state of GenServer.
  Since we only want to use this GenServer for keeping track
  of Phoenix Presence, we let the state be nil.
  """
  def init(:ok) do
    {:ok, nil}
  end

  @doc """
  Call event for tracking a given channel, from the given id.
  """
  def handle_call({:track, id}, _from, state) do
    :ok = Endpoint.subscribe("players:" <> id, [])
    {:reply, :ok, state}
  end

  @doc """
  Handles presence_diff events with no leaves.
  When there's no leaves in the given event, there's nothing to do be done.
  """
  def handle_info(%Broadcast{event: "presence_diff", payload: %{leaves: %{} = leaves}}, state)
      when leaves == %{} do
    {:noreply, state}
  end

  @doc """
  Handles presence_diff events with leaves.
  When a player leaves the channel, we unsubscribe to his topic, and
  remove him from the state.
  In a new process we alert all the matches he may have had, that he has left.
  """
  def handle_info(%Broadcast{event: "presence_diff", payload: %{leaves: leaves}}, state) do
    [{name, server} | _] =
      leaves
      |> Map.values()
      |> Enum.map(fn %{metas: [%{name: name, server: server}]} -> {name, server} end)

    result = ServerMapper.remove_player(name, server)

    unless result == :error do
      {:ok, player} = result

      Task.start(fn ->
        [topic | _] = Map.keys(leaves)
        Endpoint.unsubscribe("players:" <> topic)
        server_players = ServerMapper.get_players(player)

        player
        |> Players.get_matches(server_players)
        |> PlayersChannel.broadcast_unmatches(player)
      end)
    end

    {:noreply, state}
  end

  @doc false
  def handle_info(_, state) do
    {:noreply, state}
  end

  @doc """
  Tracks the given player such that we from within the LeaveTracker
  will be notified if the user has dropped their connection, and
  can do the necessary cleaning up.
  ## Examples
  iex> BuddyMatching.PlayerServer.track(123)
  """
  def track(id) do
    GenServer.call(__MODULE__, {:track, id})
  end
end
