defmodule BuddyMatchingWeb.PlayersChannel do
  @moduledoc """
  The channel on which all player matching is handled.
  """

  use BuddyMatchingWeb, :channel
  require Logger
  require OK

  alias BuddyMatching.Players
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Criteria.PlayerCriteria
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatching.PlayerServer.ServerExtractor
  alias BuddyMatchingWeb.Endpoint
  alias BuddyMatchingWeb.Presence
  alias BuddyMatchingWeb.Presence.LeaveTracker
  alias Phoenix.Socket.Broadcast

  @initial_matches_event "initial_matches"
  @new_match_event "new_match"
  @unmatch_event "remove_player"
  @request_event "match_requested"
  @request_response_event "request_response"
  @already_signed_up_event "already_signed_up"

  @doc """
  Broadcasts a @new_match_event of the given player to the given list
  of matches for that player.
  """
  def broadcast_matches(matches, player), do: broadcast_event(matches, player, @new_match_event)

  @doc """
  Broadcasts a @unmatch_event of the given player to the given list
  of matches for that player.
  """
  def broadcast_unmatches(matches, player), do: broadcast_event(matches, player, @unmatch_event)

  # Utility method for broadcasting the given player as given event
  # to all players in the given list of matches.
  defp broadcast_event(matches, player, event) do
    matches
    |> Enum.each(fn match ->
      Endpoint.broadcast!("players:#{match.id}", event, player)
    end)
  end

  # Private utility function for telling the LeaveTracker
  # to keep track of this player, such that they may be removed
  # from their PlayerServer at a later time.
  defp track_player_id(player) do
    :leave_tracker
    |> :global.whereis_name()
    |> LeaveTracker.track(player.id)
  end

  # HACK - to correctly get id for various types. Mostly to make tests work.
  # Tests should probably be adapted or it should be handled in a cleaner way.
  # Generally due to 'other_player' being currently not being possible to parse
  # as json, since it will not contain userInfo in given context.
  def get_player_id(%Player{} = player), do: player.id
  def get_player_id(%{} = player), do: player["id"]

  @doc """
  Parse player from the payload, if we get a player struct, we just return it,
  else we parse the payload as json
  """
  def parse_player_payload(%Player{} = player), do: {:ok, player}
  def parse_player_payload(%{"payload" => player}), do: Player.from_json(player)
  def parse_player_payload(%{} = player), do: Player.from_json(player)

  @doc """
  Send necessary match/unmatch events to new/old matches given a Player's
  old state, and its new state. Returns the list of the Player's updated matches.
  """
  def update_criteria(current_player, updated_player) do
    server_players = ServerMapper.get_players(current_player)
    current_matches = Players.get_matches(current_player, server_players)

    ServerMapper.update_player(updated_player)
    updated_matches = Players.get_matches(updated_player, server_players)

    # broadcast new_player to newly matched players
    (updated_matches -- current_matches)
    |> broadcast_matches(updated_player)

    # broadcast remove_player to players who are no longer matched
    (current_matches -- updated_matches)
    |> broadcast_unmatches(updated_player)

    # send the full list of updated matches on the socket
    Logger.debug(fn -> "Pushing new players: #{inspect(updated_matches)}" end)
    updated_matches
  end

  @doc """
  Each clients joins their own player channel players:session_id
  """
  def join("players:" <> session_id, %{} = player, socket) do
    if socket.assigns.session_id == session_id do
      case parse_player_payload(player) do
        {:error, reason} ->
          {:error, %{reason: reason}}

        {:ok, %Player{id: id} = player} when id == session_id ->
          socket = assign(socket, :user, player)
          send(self(), {:on_join, {}})
          send(self(), :after_join)
          {:ok, socket}

        _ ->
          {:error, %{reason: "session id mismatch"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  On join we find players matching the newly joined player,
  return a list of matching players to the newly joined player with an 'initial_matches' event,
  and notify each of the matches about the newly joined player as well with a 'new_match' event.

  If the given player is already signed up we return a @already_signed_up_event instead.
  """
  def handle_info({:on_join, _msg}, socket) do
    Task.start(fn ->
      case ServerMapper.add_player(socket.assigns.user) do
        :ok ->
          players = ServerMapper.get_players(socket.assigns.user)
          matches = Players.get_matches(socket.assigns.user, players)
          # Send all matching players
          push(socket, @initial_matches_event, %{players: matches})
          # Send the newly joined user to all matching players
          broadcast_matches(matches, socket.assigns.user)
          send(socket.transport_pid, :garbage_collect)

        :error ->
          push(socket, @already_signed_up_event, %{
            reason: "The given summoner is already signed up"
          })
      end
    end)

    {:noreply, socket}
  end

  @doc """
  After joining, let Presence track when a certain user joins the channel.
  This has the added benefit of allowing Presence to track the channel and handle
  potential crashes.
  """
  def handle_info(:after_join, socket) do
    # Presence has to track some metadata, and in our case we track the name and the
    # server, as we need these to remove the Player from the correct PlayerServer
    # when they leave.
    server = ServerExtractor.server_from_player(socket.assigns.user)
    tracked = %{name: socket.assigns.user.name, server: server}
    {:ok, _} = Presence.track(socket, socket.assigns.user.id, tracked)
    track_player_id(socket.assigns.user)
    {:noreply, socket}
  end

  @doc """
  Catch all Presence 'presence_diff' events and merely ignore them for now.
  These will occur when someone joins/leaves the topic, thus only when the PlayerServer
  subscribes to monitor the topic.
  """
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, socket}
  end

  @doc """
  When a player requests a match, we get the reqested player's id.
  We then send the requested player a "match_requested", who is accepted to send back
  a confirmation response, saying whether he received the request and was available,
  or whether he was busy. This is handled in the frontend using the "respond_to_request" event.
  """
  def handle_in("request_match", %{"player" => other_player}, socket) do
    id = get_player_id(other_player)

    Logger.debug(fn -> "Broadcast match request to #{id}: #{inspect(socket.assigns.user)}" end)
    Endpoint.broadcast!("players:#{id}", @request_event, socket.assigns.user)
    {:noreply, socket}
  end

  @doc """
  The event used for responding to a match_request. This is used both for cancellation
  from the requester and accept/rejection of the requested player. The response is sent
  as is to the player with the given id in the event.
  """
  def handle_in("respond_to_request", %{"id" => id, "response" => response}, socket) do
    Logger.debug(fn -> "Broadcast request response to #{id}: #{inspect(response)}" end)
    Endpoint.broadcast!("players:#{id}", @request_response_event, %{response: response})
    {:noreply, socket}
  end

  @doc """
  When update criteria is received with a new criteria for the player bound to the socket,
  we broadcast a 'new_player'
  """
  def handle_in("update_criteria", criteria, socket) do
    current_player = socket.assigns.user
    game = current_player.game

    OK.try do
      game_criteria <- Player.game_criteria_from_json(game, criteria["gameCriteria"])
      player_criteria <- PlayerCriteria.from_json(criteria["playerCriteria"])
    after
      updated_player = %{current_player | criteria: player_criteria}
      updated_player = put_in(updated_player.game_info.game_criteria, game_criteria)
      socket = assign(socket, :user, updated_player)

      Task.start(fn ->
        updated_matches = update_criteria(current_player, updated_player)
        push(socket, @initial_matches_event, %{players: updated_matches})
        send(socket.transport_pid, :garbage_collect)
      end)

      {:noreply, socket}
    rescue
      _ ->
        push(socket, "bad criteria", %{reason: "The given criteria payload could not be parsed"})
        {:noreply, socket}
    end
  end
end
