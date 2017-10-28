defmodule LolBuddyWeb.AuthController do
    use LolBuddyWeb, :controller
    action_fallback CarExtractorWeb.FallbackController

    alias LolBuddy.RiotApi.Api
    alias LolBuddy.Auth


  def show(conn, _param) do
     session_id = Auth.generate_session_id
     token = Auth.generate_session_token(session_id)

     json conn, %{session_id: session_id, session_token: token}

  end
end
  
  
