defmodule LolBuddy.Auth do
    
    def generate_session_id do
        UUID.uuid4() 
    end

    def generate_session_token(session_id) do
        Phoenix.Token.sign(LolBuddyWeb.Endpoint, "session", session_id)
    end

end