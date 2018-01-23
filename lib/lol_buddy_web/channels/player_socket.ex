defmodule LolBuddyWeb.PlayerSocket do
  use Phoenix.Socket
  alias LolBuddy.Auth

  ## Channels
  channel("players:*", LolBuddyWeb.PlayersChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket, timeout: 100_000)

  # O n connect verify that the session and session token match
  def connect(%{"session_id" => session_id, "session_token" => session_token}, socket) do
    if Auth.verify_session(session_id, session_token) do
      socket = assign(socket, :session_id, session_id)
      {:ok, socket}
    else
      :error
    end
  end

  # If no session token and id are sent just return adn error
  def connect(_params, _socket) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets
  # for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     LolBuddyWeb.Endpoint.broadcast("user_socket:#{user.id}",
  #                                    "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "user_socket:#{socket.assigns.session_id}"
end
