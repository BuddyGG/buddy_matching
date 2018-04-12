defmodule FortniteApi do
  @moduledoc """
  This module handles all interaction with Fortnite's Unofficial API.
  It is expected to be accessed through 'RiotApi.fetch_user_info/2'.
  """

  require OK
  alias FortniteApi.Stats
  alias Poison.Parser
  alias HTTPoison

  @oath_token_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/token"
  @oath_exchange_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/exchange"

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok, Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, body}
  end

  defp get_headers_basic(token), do: [{"Authorization", "basic #{token}"}]
  defp get_headers_bearer(token), do: [{"Authorization", "bearer #{token}"}]

  def refresh_token() do
    token = Application.fetch_env!(:fortnite_api, :fortnite_api_key_client)
    headers = get_headers_basic(token)

    token_body =
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", token}, {"includePerms", true}]}

    @oath_token_url
    |> HTTPoison.post(token_body, headers)
    |> handle_json()
  end

  # fetches an initial oauth token based on login creds
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

  # fetches an oauth exchange token based on initial oauth token
  defp fetch_oauth_exchange(access_token) do
    headers = get_headers_bearer(access_token)

    @oath_exchange_url
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  # this results in the final valid token
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
    OK.for do
      oath <- fetch_oauth()
      access_token <- Map.fetch(oath, "access_token")
      exchange <- fetch_oauth_exchange(access_token)
      exchange_code <- Map.fetch(exchange, "code")
      result <- fetch_oauth(exchange_code)
    after
      {result["access_token"], result["refresh_token"]}
    end
  end

  defp fetch_account_id(username, access_token) do
    headers = get_headers_bearer(access_token)

    "https://persona-public-service-prod06.ol.epicgames.com/persona/api/public/account/lookup?q=#{
      username
    }"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  defp fetch_br_stats(account_id, access_token) do
    headers = get_headers_bearer(access_token)

    "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/stats/accountId/#{
      account_id
    }/bulk/window/alltime"
    |> HTTPoison.get(headers)
    |> handle_json()
  end

  def fetch_stats(username, platform) do
    OK.for do
      {access_token, _refresh_token} <- fetch_access_tokens()
      account_info <- fetch_account_id(username, access_token)
      account_id <- Map.fetch(account_info, "id")
      display_name <- Map.fetch(account_info, "displayName")
      stats <- fetch_br_stats(account_id, access_token)
    after
      stats
      |> Stats.get_duo_stats(platform)
      |> Map.put("username", display_name)
      |> Map.put("platform", platform)
    end
  end
end
