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

  @login_url "https://www.epicgames.com/id/api/login"
  @csrf_url "https://www.epicgames.com/id/api/csrf"
  @exchange_url "https://www.epicgames.com/id/api/exchange"
  @oauth_token_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/token"

  @doc """
  Starts the AcessServer as a singleton registered
  with the name of the module.

  ## Examples
  iex> {:ok, pid} = FortniteApi.AcessServer.start_link()
  {:ok, #PID<0.246.0>}

  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  defp initial_state(), do: {"", "", DateTime.utc_now()}
  defp handle_json({:ok, %{status_code: 200, body: body}}), do: {:ok, Parser.parse!(body)}
  defp handle_json({_, %{status_code: _, body: body}}), do: {:error, body}

  @doc """
  Returns the required authorization headers with bearer prefix for the given token"

  ## Examples
  #
    iex> AccessServer.get_headers_basic("token")
    [{"Authorization", "basic token"}]

  """
  def get_headers_basic(token), do: [{"Authorization", "basic #{token}"}]

  @doc """
  Returns the required authorization headers with bearer prefix for the given token"

  ## Examples

    iex> AccessServer.get_headers_bearer("token")
    [{"Authorization", "bearer token"}]

  """
  def get_headers_bearer(token), do: [{"Authorization", "bearer #{token}"}]

  @doc """
  Get the session cookies associated with an HTTPoison response
  """
  def get_session_cookies(response) do
    response.headers
    |> Enum.filter(fn {key, _} -> String.match?(key, ~r/\Aset-cookie\z/i) end)
    |> Enum.map(fn {_, v} -> :hackney_cookie.parse_cookie(v) end)
    |> Enum.map(fn [{name, value} | _opts] -> name <> "=" <> value end)
  end

  # Simply get the XSRF token from the cookies
  # Assumes it exists in the cookies
  defp get_xsrf_from_cookies(cookies) do
    cookies
    |> Enum.find(fn s -> String.starts_with?(s, "XSRF-TOKEN") end)
    |> String.split("=")
    |> Enum.at(1)
    |> case do
      nil -> {:error, "No XSRF"}
      token -> {:ok, token}
    end
  end

  @doc """
  Fetch a session in the form of a list of cookies and an xsrf token.
  Returns: {:ok, xsrf, cookies} or {:error, <msg>}
  """
  def fetch_session() do
    # first we get an xsrf token and the corresponding cookies
    with {:ok, response} <- HTTPoison.get(@csrf_url),
         cookies <- get_session_cookies(response),
         {:ok, xsrf} <- get_xsrf_from_cookies(cookies) do
      {:ok, xsrf, cookies}
    else
      _ -> {:error, "Couldn't fetch session"}
    end

    # now we do a basic login
  end

  defp try_login(xsrf, cookies) do
    with {:ok, email} <- Application.fetch_env(:fortnite_api, :fortnite_api_email),
         {:ok, password} <- Application.fetch_env(:fortnite_api, :fortnite_api_password) do
      header = [{"x-xsrf-token", xsrf}]
      formatted_cookies = Enum.join(cookies, "; ")

      body =
        {:form,
         [
           {"email", email},
           {"password", password},
           {"rememberMe", true}
         ]}

      HTTPoison.post(@login_url, body, header, hackney: [cookie: formatted_cookies])
    else
      _ -> {:error, "Credentials missing for login"}
    end
  end

  defp try_exchange_login(xsrf, cookies) do
    header = [{"x-xsrf-token", xsrf}]
    formatted_cookies = Enum.join(cookies, "; ")
    HTTPoison.get(@exchange_url, header, hackney: [cookie: formatted_cookies])
  end

  def fetch_login_code() do
    with {:ok, xsrf, cookies} <- fetch_session(),
         {:ok, response} <- try_login(xsrf, cookies),
         new_cookies <- get_session_cookies(response) ++ cookies,
         {:ok, response} <- try_exchange_login(xsrf, new_cookies),
         {:ok, %{"code" => code}} <- Poison.decode(response.body) do
      {:ok, code}
    else
      _ -> {:error, "Couldn't get login code"}
    end
  end

  defp fetch_refreshed_tokens(refresh_token) do
    Logger.debug(fn -> "Refreshing access token for Fortnite API" end)
    key_client = Application.fetch_env!(:fortnite_api, :fortnite_api_key)
    headers = get_headers_basic(key_client)

    token_body =
      {:form,
       [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}, {"includePerms", true}]}

    @oauth_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  # This results in the final valid access_token
  defp fetch_oauth(exchange_code) do
    client_token = Application.fetch_env!(:fortnite_api, :fortnite_api_key)
    headers = get_headers_basic(client_token)

    token_body =
      {:form,
       [
         {"grant_type", "exchange_code"},
         {"exchange_code", exchange_code},
         {"token_type", "egl"},
         {"includePerms", true}
       ]}

    @oauth_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  # Executes the full set of requests needed to
  # retrieve a new access token.
  def fetch_access_tokens() do
    OK.for do
      code <- fetch_login_code()
      res <- fetch_oauth(code)
    after
      res
    end
  end

  # Returns the new state for the AccessServer given a result
  # from a access token query.
  defp res_to_state(%{
         "access_token" => access,
         "refresh_token" => refresh,
         "expires_at" => expiration_string
       }) do
    {:ok, expiration, _} = DateTime.from_iso8601(expiration_string)
    {access, refresh, expiration}
  end

  @doc """
  Called automatically by start_link.
  We instantiate the AccessServer with DateTime.utc_now/0
  as its expiration, causing the server to try to get a new
  access token next time it get_token/0 is called.

  Returns :ok and initial state of GenServer.
  """
  def init(:ok) do
    {:ok, initial_state()}
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

  # Attempts to get entirely new tokens given a state.
  # If acquiring new tokens fails, returns an error stating so and leaves
  # the GenServer in the given state.
  # Returns a correctly formatted response from the AccessServer of format:
  # {:reply, return_val, state}
  defp try_get_access_tokens(state) do
    OK.try do
      res <- fetch_access_tokens()
      new_state = res_to_state(res)
    after
      {:reply, {:ok, elem(new_state, 0)}, new_state}
    rescue
      _ -> {:reply, {:error, "Couldn't refresh nor get a new access token"}, state}
    end
  end

  # Attempts to refresh tokens given a state.
  # If refreshing fails, tries to get a brand new access tokens.
  # Returns a correctly formatted response from the AccessServer of format:
  # {:reply, return_val, state}
  defp try_refresh_tokens({_, refresh, _} = state) do
    OK.try do
      res <- fetch_refreshed_tokens(refresh)
      new_state = res_to_state(res)
    after
      {:reply, {:ok, elem(new_state, 0)}, new_state}
    rescue
      _ -> try_get_access_tokens(state)
    end
  end

  @doc """
  Forces a refresh of the access token before returning,
  even if it has not expired yet.
  Handle calls with read - synchronous.

  Returns {:reply, <value returned to client>, <state>}
  """
  def handle_call({:force_refresh}, _from, state) do
    try_refresh_tokens(state)
  end

  @doc """
  Returns the access token, refreshing it prior to return
  if it has exceeded its expiration date.
  Handle calls with read - synchronous

  Returns {:reply, <value returned to client>, <state>}
  """
  def handle_call({:get_token}, _from, {access, _refresh, expiration} = state) do
    if is_expired?(expiration) do
      try_refresh_tokens(state)
    else
      {:reply, {:ok, access}, state}
    end
  end

  @doc """
  Resets the AccessServer to its initial state
  with DateTime.utc_now as its expiration.
  Handle calls with read - synchronous

  Returns {:reply, <value returned to client>, <state>}
  """
  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, initial_state()}
  end

  @doc """
  Forces the AccessServer to reset it's state.
  The state will be {"", "", DateTime.utc_now}.
  Primarily made for testing.

  ## Examples

  iex> FortniteApi.AccessServer.reset()
  :ok
  """
  def reset() do
    GenServer.call(__MODULE__, {:reset})
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
