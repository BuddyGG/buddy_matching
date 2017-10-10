defmodule LolBuddyWeb.PlayersChannel do
  use LolBuddyWeb, :channel
  alias LolBuddy.Players
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

  def handle_in("request_match", %{"player" => other_player}, socket) do
    id = get_player_id(other_player)
    push socket, "requesting_match", other_player
    LolBuddyWeb.Endpoint.broadcast! "players:#{id}", "match_requested", socket.assigns[:user]
    {:noreply, socket}
  end

  def handle_in("respond_to_request", %{"id" => id, "response" => response}, socket) do
    push socket, "request_response", %{response: response} 
    LolBuddyWeb.Endpoint.broadcast! "players:#{id}", "request_response", %{response: response} 
    {:noreply, socket}
  end

  #TODO when channel closes due to errors
  def terminate(_, socket) do
    RegionMapper.remove_player(socket.assigns[:user])
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
