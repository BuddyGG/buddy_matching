defmodule FortniteApi.AccessServer do
  @moduledoc """
  Simple singleton GenServer for accessing a singled shared
  Fortnite Access Token. All calls are handled synchronously,
  and the token is refreshed upon expiration, or when calls
  to force_refresh/0 occur.
  """
  use GenServer
  require Logger
  require OK
  alias Poison.Parser
  alias HTTPoison

  @oath_token_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/token"
  @oath_exchange_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/exchange"

  @doc """
  Starts the AccessServer.
  ## Examples

    iex> {:ok, pid} = FortniteApi.AccessServer.start_link
    {:ok, #PID<0.246.0>}

  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  This specific initializer is used by ExUnit.

  Starts the AcessServer with potential options.
  These are described here:
  https://hexdocs.pm/elixir/GenServer.html#start_link/3
  ## Examples
  #
    iex> {:ok, pid} = FortniteApi.AcessServer.start_link

  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  defp handle_json({:ok, %{status_code: 200, body: body}}), do: {:ok, Parser.parse!(body)}
  defp handle_json({_, %{status_code: _, body: body}}), do: {:error, body}
  defp get_headers_basic(token), do: [{"Authorization", "basic #{token}"}]
  defp get_headers_bearer(token), do: [{"Authorization", "bearer #{token}"}]

  defp refresh_token(refresh_token) do
    Logger.debug(fn -> "Refreshing access token for Fortnite API" end)
    key_client = Application.fetch_env!(:fortnite_api, :fortnite_api_key_client)
    headers = get_headers_basic(key_client)

    token_body =
      {:form,
       [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}, {"includePerms", true}]}

    @oath_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  # Fetches an initial oauth token based on login creds
  defp fetch_oauth() do
    email = Application.fetch_env!(:fortnite_api, :fortnite_api_email)
    password = Application.fetch_env!(:fortnite_api, :fortnite_api_password)
    launch_token = Application.fetch_env!(:fortnite_api, :fortnite_api_key_launcher)
    headers = get_headers_basic(launch_token)

    token_body =
      {:form,
       [
         {"grant_type", "password"},
         {"username", email},
         {"password", password},
         {"includePerms", true}
       ]}

    @oath_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  # Fetches an oauth exchange token based on initial oauth token
  defp fetch_oauth_exchange(access_token) do
    headers = get_headers_bearer(access_token)

    @oath_exchange_url
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  # This results in the final valid access_token
  defp fetch_oauth(exchange_code) do
    client_token = Application.fetch_env!(:fortnite_api, :fortnite_api_key_client)
    headers = get_headers_basic(client_token)

    token_body =
      {:form,
       [
         {"grant_type", "exchange_code"},
         {"exchange_code", exchange_code},
         {"token_type", "egl"},
         {"includePerms", true}
       ]}

    @oath_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  defp fetch_access_tokens() do
    Logger.debug(fn -> "Fetching new access token for Fortnite API" end)

    OK.for do
      oath <- fetch_oauth()
      access_token <- Map.fetch(oath, "access_token")
      exchange <- fetch_oauth_exchange(access_token)
      exchange_code <- Map.fetch(exchange, "code")
      res <- fetch_oauth(exchange_code)
    after
      res
    end
  end

  # Returns an error tuple with the res from fetch_access_tokens/0
  # or refresh_token/0 parsed and formatted as the state
  defp res_to_state(res) do
    OK.for do
      access <- Map.fetch(res, "access_token")
      refresh <- Map.fetch(res, "refresh_token")
      expiration_string <- Map.fetch(res, "expires_at")
      {:ok, expiration, _} = DateTime.from_iso8601(expiration_string)
    after
      {access, refresh, expiration}
    end
  end

  @doc """
  Called automatically by start_link.
  Returns :ok and initial state of GenServer.
  """
  def init(:ok) do
    OK.for do
      res <- fetch_access_tokens()
      state <- res_to_state(res)
    after
      state
    end
  end

  # Compares the expiration of the token against current time
  # and returns true if the expiration is smaller than current time.
  defp is_expired?(expiration) do
    now = DateTime.utc_now()

    case DateTime.compare(now, expiration) do
      :lt -> false
      _ -> true
    end
  end

  # Forces a refresh of the access token before returning,
  # even if it has not expired yet.
  # Handle calls with read - synchronous.
  # Returns {:reply, <value returned to client>, <state>}
  def handle_call({:force_refresh}, _from, {_, refresh, _} = state) do
    case refresh_token(refresh) do
      {:ok, res} ->
        new_state = res_to_state(res)
        {:reply, {:ok, elem(new_state, 0)}, new_state}

      {:error, _} ->
        {:reply, {:error, "Couldn't refresh access token"}, state}
    end
  end

  # Returns the access token, refreshing it prior to return
  # if it has exceeded its expiration date.
  # Handle calls with read - synchronous
  # Returns {:reply, <value returned to client>, <state>}
  def handle_call({:get_token}, _from, {access, refresh, expiration} = state) do
    if is_expired?(expiration) do
      case refresh_token(refresh) do
        {:ok, res} ->
          new_state = res_to_state(res)
          {:reply, {:ok, elem(new_state, 0)}, new_state}

        {:error, _} ->
          {:reply, {:error, "Couldn't refresh access token"}, state}
      end
    else
      {:reply, {:ok, access}, state}
    end
  end

  @doc """
  Forces a refresh of the servers access token prior to returning.
  Otherwise behaves identical to get_token/0

  ## Examples

    iex> FortniteApi.AccessServer.force_refresh()
    {:ok, token}
    iex> FortniteApi.AccessServer.get_token()
    {:error, "Couldn't refresh expired token"}

  """
  def force_refresh() do
    GenServer.call(__MODULE__, {:force_refresh})
  end

  @doc """
  Returns an ok tuple containing an access token for FortniteApi.
  If the token has gone past its given expiration date, it will be refreshed
  prior to returning. If it could not be refreshed, an error will be returned.

  ## Examples

    iex> FortniteApi.AccessServer.force_refresh()
    {:ok, token}
    iex> FortniteApi.AccessServer.get_token()
    {:error, "Couldn't refresh expired token"}

  """
  def get_token() do
    GenServer.call(__MODULE__, {:get_token})
  end
end
