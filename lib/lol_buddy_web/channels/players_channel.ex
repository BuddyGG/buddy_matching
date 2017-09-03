defmodule LolBuddyWeb.PlayersChannel do
  use LolBuddyWeb, :channel

  def join("players:lobby", payload, socket) do
    if authorized?(payload) do
      %{"cookie_id" => id} = payload
      socket = assign(socket, :user, id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  ## On new player event check if the the new players is relevant for the current player
  intercept ["new_player"]
  def handle_out("new_player", payload, socket) do
    case socket.assigns[:player] == 1 do
      true -> {:noreply, socket}
      false -> 
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
