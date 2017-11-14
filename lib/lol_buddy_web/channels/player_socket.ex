defmodule LolBuddyWeb.PlayerSocket do
  use Phoenix.Socket
  alias LolBuddy.Auth

  ## Channels
  channel "players:*", LolBuddyWeb.PlayersChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"session_id" => session_id, "session_token" => session_token}, socket) do
    if Auth.verify_session(session_id, session_token) do
        socket = assign(socket, :session_id, session_id)
        {:ok, socket}
    else
        {:error, %{reason: "unauthorized"}}
    end
  end

  def connect(_params, _socket) do
    {:error, %{reason: "Missing session_id or session_token"}}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     LolBuddyWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
