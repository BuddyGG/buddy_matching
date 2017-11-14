defmodule LolBuddy.Auth do
    @salt "session"
    #Tokens are valid for 30 days
    @max_age 86400 * 30

    def generate_session_id do
        UUID.uuid4() 
    end

    def generate_session_token(session_id) do
        Phoenix.Token.sign(LolBuddyWeb.Endpoint, @salt, session_id, max_age: @max_age )
    end

    def verify_session(session_id, session_token) do
        case Phoenix.Token.verify(LolBuddyWeb.Endpoint, @salt, session_token, max_age: @max_age) do
            {:ok, id_from_token} -> id_from_token == session_id
            {:error, _error } -> false
        end
    end

end