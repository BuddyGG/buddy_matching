defmodule LolBuddyWeb.PlayersChannel do
  use LolBuddyWeb, :channel
  alias LolBuddy.Players.Player
  alias LolBuddy.Players

  def join("players:lobby", payload, socket) do
    if authorized?(payload) do
      %{"cookie_id" => id} = payload
      socket = assign(socket, :user, %Player{id: id})
      send(self(), {:on_join, {}})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:on_join, _msg}, socket) do
    broadcast! socket, "new_player", socket.assigns[:user]
    push socket, "new_players", %{players: Players.find_matches(socket.assigns[:user], [])}
    {:noreply, socket}
  end

  ## On new player event check if the the new players is relevant for the current player
  intercept ["new_player"]
  def handle_out("new_player", payload, socket) do
    case Players.match?(socket.assigns[:user], payload) do
      false -> {:noreply, socket}
      true -> 
        push socket, "new_player", payload
        {:noreply, socket}
    end
  end

  ## ensure that only users with a id can join
  defp authorized?(%{"cookie_id" => _id}) do
    true
  end
  
  defp authorized?(_payload) do
    false
  end
end
