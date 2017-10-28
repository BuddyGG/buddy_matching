defmodule LolBuddyWeb.PlayersChannel do
  use LolBuddyWeb, :channel
  require Logger

  alias LolBuddy.Players
  alias LolBuddy.Players.Criteria
  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer.RegionMapper


  @doc """
  Each clients joins their own player channel players:cookie_id 
  """
  #TODO auth users
  def join("players:" <> cookie_id, player, socket) do
      socket = assign(socket, :user, parse_player_payload(player))
      send(self(), {:on_join, {}})
      {:ok, socket}
  end

  @doc """
  On join we find players mathing the newly joined player,
  return the list of mathing players to the newly joined player
  and notifies each of the mathing players about the newly joined players aswell
  """
  def handle_info({:on_join, _msg}, socket) do
    region_players = RegionMapper.get_players(socket.assigns[:user].region)
    matching_players = Players.get_matches(socket.assigns[:user], region_players)
    RegionMapper.add_player(socket.assigns[:user])

    #Send all matching players
    push socket, "new_players", %{players: matching_players}
    
    #Send the newly joined user to all matching players
    matching_players
    |> Enum.each(fn player ->
      LolBuddyWeb.Endpoint.broadcast! "players:#{player.id}", "new_player", socket.assigns[:user]
    end)
    
    {:noreply, socket}
  end

  @doc """
  When a player requests a match, we get the reqested player's id
  and push a "requesting_match" event to his socket.
  Other than this, we return a "match_requested" event to the player doing the request
  to confirm the request, such that relevant actions can be taken in the front end.
  """
  def handle_in("request_match", %{"player" => other_player}, socket) do
    id = get_player_id(other_player)
    push socket, "requesting_match", other_player
    LolBuddyWeb.Endpoint.broadcast! "players:#{id}", "match_requested", socket.assigns[:user]
    {:noreply, socket}
  end

  @doc """
  The event used for responding to a match_request. This is used both for cancellation
  from the requester and accept/rejection of the requested player. The response is sent
  as is to the player with the given id in the event.
    """
  def handle_in("respond_to_request", %{"id" => id, "response" => response}, socket) do
    push socket, "request_response", %{response: response} 
    LolBuddyWeb.Endpoint.broadcast! "players:#{id}", "request_response", %{response: response} 
    {:noreply, socket}
  end

  @doc """
  When update criteria is received with a new criteria for the player bound to the socket,
  we broadcast a 'new_player' 

    """
  def handle_in("update_criteria", criteria, socket) do
    RegionMapper.remove_player(socket.assigns[:user])
    region_players = RegionMapper.get_players(socket.assigns[:user].region)
    Logger.debug "Region Players: #{inspect region_players}"
    current_matches = Players.get_matches(socket.assigns[:user], region_players)
    updated_criteria = Criteria.from_json(criteria)
    updated_player = %{socket.assigns[:user] | criteria: updated_criteria}
    RegionMapper.add_player(updated_player)
    updated_matches = Players.get_matches(updated_player, region_players)

    #update socket's player
    socket = assign(socket, :user, updated_player)

    # broadcast new_player to newly matched players
    updated_matches -- current_matches
    |> Enum.each(fn player ->
        LolBuddyWeb.Endpoint.broadcast! "players:#{player.id}", "new_player", updated_player
      end)

    # broadcast remove_player to players who are no longer matched
    current_matches -- updated_matches
    |> Enum.each(fn player ->
        LolBuddyWeb.Endpoint.broadcast! "players:#{player.id}", "remove_player", updated_player
      end)

    # send the full list of updated matches on the socket
    push socket, "new_players", %{players: updated_matches}
    {:noreply, socket}
  end

  #TODO when channel closes due to errors
  def terminate(_, socket) do
    RegionMapper.remove_player(socket.assigns[:user])
    region_players = RegionMapper.get_players(socket.assigns[:user].region)
    matching_players = Players.get_matches(socket.assigns[:user], region_players)

    #Tell all the mathing players that the player left
    matching_players
    |> Enum.each(fn player ->
      LolBuddyWeb.Endpoint.broadcast! "players:#{player.id}", "player_left", socket.assigns[:user]
    end)

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
