defmodule BuddyMatchingWeb.Presence.LeaveTracker do
  @moduledoc """
  Simple GenServer for handling Phoenix Presence,
  and keeping track of Player's leaving, for which it will ensure
  that they are removed from their related PlayerServer.
  """
  use GenServer
  require Logger
  alias BuddyMatching.Players
  alias BuddyMatching.PlayerServer.RegionMapper
  alias BuddyMatchingWeb.Endpoint
  alias BuddyMatchingWeb.PlayersChannel
  alias Phoenix.Socket.Broadcast

  @doc """
  Starts the LeaveTracker with potential options.
  These are described here:
  https://hexdocs.pm/elixir/GenServer.html#start_link/3
  ## Examples
  iex> {:ok, pid} = BuddyMatching.LeaveTracker.start_link
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # Called automatically by start_link
  # Returns :ok and initial state of GenServer
  # -- Since we only want to use this GenServer for keeping track
  # of Phoenix Presence, we let the state be nil.
  def init(:ok) do
    {:ok, nil}
  end

  def handle_call({:track, id}, _from, state) do
    :ok = Endpoint.subscribe("players:" <> id, [])
    {:reply, :ok, state}
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
    [{name, region} | _] =
      leaves
      |> Map.values()
      |> Enum.map(fn %{metas: [%{name: name, region: region}]} -> {name, region} end)

    result = RegionMapper.remove_player(name, region)

    unless result == :error do
      {:ok, player} = result

      Task.start(fn ->
        [topic | _] = Map.keys(leaves)
        Endpoint.unsubscribe("players:" <> topic)
        region_players = RegionMapper.get_players(player.game_info.region)

        player
        |> Players.get_matches(region_players)
        |> PlayersChannel.broadcast_unmatches(player)
      end)
    end

    {:noreply, state}
  end

  # We ignore all other messages
  def handle_info(_, state) do
    {:noreply, state}
  end

  @doc """
  Tracks the given player such that we from within the
  LeaveTracker will be notified if the user has dropped their
  connection.
  ## Examples
  iex> BuddyMatching.PlayerServer.track(123)
  """
  def track(pid, id) do
    GenServer.call(pid, {:track, id})
  end
end
