defmodule FortniteApi.AccessServerMockTest do
  alias FortniteApi.AccessServer
  alias FortniteApi.AccessServer
  use ExUnit.Case, async: false

  import Mock

  @email "test@mail.com"
  @password "password"
  @key_client "key_client"
  @key_launcher "key_launcher"
  @oauth_token_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/token"
  @oauth_exchange_url "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/exchange"
  @token "MOCK_TOKEN"

  setup_all do
    Application.put_env(:fortnite_api, :fortnite_api_email, @email)
    Application.put_env(:fortnite_api, :fortnite_api_password, @password)
    Application.put_env(:fortnite_api, :fortnite_api_key_client, @key_client)
    Application.put_env(:fortnite_api, :fortnite_api_key_launcher, @key_launcher)
  end

  setup do
    AccessServer.reset()
  end

  defp success_response(value), do: {:ok, %{status_code: 200, body: value}}
  defp error_response(value), do: {:error, %{status_code: 404, body: value}}

  test "can't refresh access token, can get new integration test" do
    # matches initial state in AccessServer
    refresh_token = ""
    initial_token = "INITIAL_TOKEN"
    exchange_code = "EXCHANGE_CODE"

    basic_client = AccessServer.get_headers_basic(@key_client)
    basic_launcher = AccessServer.get_headers_basic(@key_launcher)
    bearer_token = AccessServer.get_headers_bearer(initial_token)

    refresh_body =
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", ""}, {"includePerms", true}]}

    initial_body =
      {:form,
       [
         {"grant_type", "password"},
         {"username", @email},
         {"password", @password},
         {"includePerms", true}
       ]}

    oauth_body =
      {:form,
       [
         {"grant_type", "exchange_code"},
         {"exchange_code", exchange_code},
         {"token_type", "egl"},
         {"includePerms", true}
       ]}

    initial_response = Poison.encode!(%{"access_token" => initial_token})
    exchange_response = Poison.encode!(%{"code" => exchange_code})

    oauth_response =
      Poison.encode!(%{
        "access_token" => @token,
        "refresh_token" => refresh_token,
        "expires_at" => DateTime.utc_now()
      })

    with_mock HTTPoison,
      post: fn
        @oauth_token_url, ^refresh_body, ^basic_client -> error_response("Can't refresh token")
        @oauth_token_url, ^initial_body, ^basic_launcher -> success_response(initial_response)
        @oauth_token_url, ^oauth_body, ^basic_client -> success_response(oauth_response)
      end,
      get: fn @oauth_exchange_url, ^bearer_token -> success_response(exchange_response) end do
      assert {:ok, @token} = AccessServer.get_token()
    end
  end

  test "can't refresh access token, nor get new token integration test" do
    with_mock HTTPoison,
      post: fn @oauth_token_url, _, _ -> error_response("Can't refresh token") end do
      assert {:error, "Couldn't refresh nor get a new access token"} = AccessServer.get_token()
    end
  end

  test "refresh token integration test" do
    new_refresh = "REFRESH_TOKEN"

    header = AccessServer.get_headers_basic(@key_client)

    body =
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", ""}, {"includePerms", true}]}

    response =
      Poison.encode!(%{
        "access_token" => @token,
        "refresh_token" => new_refresh,
        "expires_at" => DateTime.utc_now()
      })

    with_mock(
      HTTPoison,
      post: fn @oauth_token_url, ^body, ^header -> success_response(response) end
    ) do
      assert {:ok, @token} = AccessServer.get_token()
    end
  end

  test "force refresh always tries to get new token integration test" do
    token = "TOKEN"
    refresh = "REFRESH_TOKEN"
    new_refresh = "NEW_NEW_REFRESH"
    new_token = "NEW_TOKEN"
    today = DateTime.utc_now()
    tmrw = %{today | day: today.day + 1}
    tmrw_tmrw = %{tmrw | day: tmrw.day + 1}
    header = AccessServer.get_headers_basic(@key_client)

    body1 =
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", ""}, {"includePerms", true}]}

    body2 =
      {:form,
       [{"grant_type", "refresh_token"}, {"refresh_token", refresh}, {"includePerms", true}]}

    response1 =
      Poison.encode!(%{"access_token" => token, "refresh_token" => refresh, "expires_at" => tmrw})

    response2 =
      Poison.encode!(%{
        "access_token" => new_token,
        "refresh_token" => new_refresh,
        "expires_at" => tmrw_tmrw
      })

    with_mock(
      HTTPoison,
      post: fn
        @oauth_token_url, ^body1, ^header -> success_response(response1)
        @oauth_token_url, ^body2, ^header -> success_response(response2)
      end
    ) do
      assert {:ok, ^token} = AccessServer.get_token()
      assert {:ok, ^new_token} = AccessServer.force_refresh()
    end
  end

  test "get token returns immediately if not expired" do
    refresh = "NEW_REFRESH"
    today = DateTime.utc_now()
    tmrw = %{today | day: today.day + 1}
    header = AccessServer.get_headers_basic(@key_client)

    body =
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", ""}, {"includePerms", true}]}

    response =
      Poison.encode!(%{"access_token" => @token, "refresh_token" => refresh, "expires_at" => tmrw})

    with_mock(
      HTTPoison,
      post: fn
        @oauth_token_url, ^body, ^header -> success_response(response)
        @oauth_token_url, _body, _header -> error_response("If you refresh again, you will fail.")
      end
    ) do
      assert {:ok, @token} = AccessServer.get_token()
      assert {:ok, @token} = AccessServer.get_token()
    end
  end
end
