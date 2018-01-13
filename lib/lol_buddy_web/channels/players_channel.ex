defmodule LolBuddyWeb.PlayersChannel do
  @moduledoc """
  The channel on which all player matching is handled.
  """

  use LolBuddyWeb, :channel
  require Logger

  alias LolBuddy.Players
  alias LolBuddy.Players.Criteria
  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer.RegionMapper
  alias LolBuddyWeb.Endpoint
  alias LolBuddyWeb.Presence
  alias Phoenix.Socket.Broadcast

  @initial_matches_event "initial_matches"
  @new_match_event "new_match"
  @unmatch_event "remove_player"
  @request_event "match_requested"
  @request_response_event "request_response"
  @already_signed_up_event "already_signed_up"

  @doc """
  Each clients joins their own player channel players:session_id
  """
  def join("players:" <> session_id, %{} = player, socket) do
      if socket.assigns.session_id == session_id do
        parsed_player = parse_player_payload(player)
        if parsed_player.id == session_id do
          socket = assign(socket, :user, parse_player_payload(player))
          send(self(), {:on_join, {}})
          send(self(), :after_join)
          {:ok, socket}
        else
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
    region_players = RegionMapper.get_players(socket.assigns.user.region)
    matches = Players.get_matches(socket.assigns.user, region_players)
    case RegionMapper.add_player(socket.assigns.user) do
      :ok ->
        #Send all matching players
        Logger.debug fn -> "Pushing new players: #{inspect matches}"  end
        push socket, @initial_matches_event, %{players: matches}

        #Send the newly joined user to all matching players
        matches
        |> Enum.each(fn player ->
           Endpoint.broadcast! "players:#{player.id}", @new_match_event, socket.assigns.user
        end)

      :error ->
        push socket, @already_signed_up_event, %{reason: "The given summoner is already signed up"}
    end
    {:noreply, socket}
  end

  @doc """
  After joining, let Presence track when a certain user joins the channel.
  This has the added benefit of allowing Presence to track the channel and handle
  potential crashes.
    """
  def handle_info(:after_join, socket) do
    # Presence has to track some metadata - so give it an empty map
    {:ok, _} = Presence.track(socket, socket.assigns.user.id,
                              %{name: socket.assigns.user.name})
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

    Logger.debug fn -> "Broadcast match request to #{id}: #{inspect socket.assigns.user}" end
    Endpoint.broadcast! "players:#{id}", @request_event, socket.assigns.user
    {:noreply, socket}
  end

  @doc """
  The event used for responding to a match_request. This is used both for cancellation
  from the requester and accept/rejection of the requested player. The response is sent
  as is to the player with the given id in the event.
  """
  def handle_in("respond_to_request", %{"id" => id, "response" => response}, socket) do
    Logger.debug fn -> "Broadcast request response to #{id}: #{inspect response}" end
    Endpoint.broadcast! "players:#{id}", @request_response_event, %{response: response}
    {:noreply, socket}
  end

  @doc """
  When update criteria is received with a new criteria for the player bound to the socket,
  we broadcast a 'new_player'
  """
  def handle_in("update_criteria", criteria, socket) do
    region_players = RegionMapper.get_players(socket.assigns.user.region)
    current_matches = Players.get_matches(socket.assigns.user, region_players)

    updated_criteria = Criteria.from_json(criteria)
    updated_player = %{socket.assigns.user | criteria: updated_criteria}
    socket = assign(socket, :user, updated_player)

    RegionMapper.update_player(updated_player)
    updated_matches = Players.get_matches(updated_player, region_players)

    # broadcast new_player to newly matched players
    updated_matches -- current_matches
    |> Enum.each(fn player ->
        Logger.debug fn -> "Broadcast new player to #{player.id}: #{inspect updated_player}" end
        Endpoint.broadcast! "players:#{player.id}", @new_match_event, updated_player
      end)

    # broadcast remove_player to players who are no longer matched
    current_matches -- updated_matches
    |> Enum.each(fn player ->
        Logger.debug fn -> "Broadcast remove player to #{player.id}: #{inspect updated_player}" end
        Endpoint.broadcast! "players:#{player.id}", @unmatch_event, updated_player
      end)

    # send the full list of updated matches on the socket
    Logger.debug fn -> "Pushing new players: #{inspect updated_matches}" end
    push socket, @initial_matches_event, %{players: updated_matches}
    {:noreply, socket}
  end

  #HACK - to correctly get id for various types. Mostly to make tests work.
  # Tests should probably be adapted or it should be handled in a cleaner way.
  # Generally due to 'other_player' being currently not being possible to parse
  # as json, since it will not contain userInfo in given context.
  def get_player_id(%Player{} = player), do: player.id
  def get_player_id(%{} = player), do: player["id"]

  @doc """
  Parse player from the payload, if we get a player struct, we just return it,
  else we parse the payload as json
  """
  def parse_player_payload(%Player{} = player), do: player
  def parse_player_payload(%{"payload" => payload}), do: Player.from_json(payload)
  def parse_player_payload(%{} = player), do: Player.from_json(player)
end
