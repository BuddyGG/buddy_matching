defmodule BuddyMatchingWeb.Auth do
  @moduledoc """
  Authenticate module using Phoenix tokens
  Used to generate session ids, tokens and verifying these
  """
  alias BuddyMatchingWeb.Endpoint
  alias Phoenix.Token

  @salt "session"

  # Tokens are valid for 30 days
  @max_age 86_400 * 30

  @doc """
  Generate a valid uuid session id.
  ## Example:
    iex> BuddyMatching.Auth.generate_session_id
      "fe8d2ecb-38d3-4b17-a745-b455ce78183b"
  """
  def generate_session_id do
    UUID.uuid4()
  end

  @doc """
  Sign a session id to a create session token with a max_age of 30 days
  ## Example
    iex> BuddyMatching.Auth.generate_session_token("fe8d2ecb-38d3-4b17-a745-b455ce78183b")
      "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkZmU4ZDJlY2ItMzhkMy00YjE3LWE3NDUtYjQ1NWNlNzgxODNiZAAGc2lnbmVkbgYAa_yf218B.a4U-ibqtnyFogL_LN9EmkDruXUuT4S_r--U6twFZSqo"
  """
  def generate_session_token(session_id) do
    Token.sign(Endpoint, @salt, session_id, max_age: @max_age)
  end

  @doc """
  Verify a session id/token pair
  ## Example
    iex> BuddyMatching.Auth.verify_session("fe8d2ecb-38d3-4b17-a745-b455ce78183b",
    "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkZmU4ZDJlY2ItMzhkMy00YjE3LWE3NDUtYjQ1NWNlNzgxODNiZAAGc2lnbmVkbgYAa_yf218B.a4U-ibqtnyFogL_LN9EmkDruXUuT4S_r--U6twFZSqo")
      true
  """
  def verify_session(session_id, session_token) do
    case Token.verify(Endpoint, @salt, session_token, max_age: @max_age) do
      {:ok, id_from_token} -> id_from_token == session_id
      {:error, _error} -> false
    end
  end
end
