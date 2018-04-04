defmodule BuddyMatchingWeb.AuthController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias BuddyMatchingWeb.Auth

  @doc """
  Get request to get a new session_id and matching token
  """
  def show(conn, _param) do
    session_id = Auth.generate_session_id()
    token = Auth.generate_session_token(session_id)
    json(conn, %{session_id: session_id, session_token: token})
  end
end
