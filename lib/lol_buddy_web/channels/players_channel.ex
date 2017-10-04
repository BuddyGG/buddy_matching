defmodule LolBuddyWeb.PlayersChannel do
  use LolBuddyWeb, :channel
  alias LolBuddy.Players
  alias LolBuddy.PlayerServer.RegionMapper


  @doc """
  Each clients joins their own player channel players:cookie_id 
  """
  #TODO auth users
  def join("players:" <> cookie_id, player, socket) do
      socket = assign(socket, :user, player)
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

  #TODO on socket close call RegionMapper.remove_player/1

end
