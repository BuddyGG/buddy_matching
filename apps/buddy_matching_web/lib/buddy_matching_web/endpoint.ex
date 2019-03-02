defmodule BuddyMatchingWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :buddy_matching_web

  socket("/socket", BuddyMatchingWeb.PlayerSocket, websocket: [timeout: 100_000])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :buddy_matching_web,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_buddy_matching_key",
    signing_salt: "XJ+2fLa6"
  )

  plug(CORSPlug)
  plug(BuddyMatchingWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      host = System.get_env("HOST") || raise "expected the HOST environment variable to be set"

      secret =
        System.get_env("SECRET_KEY_BASE") ||
          raise "expected the SECRET_KEY_BASE environment variable to be set"

      config =
        config
        |> Keyword.put(:http, [:inet6, port: port])
        |> Keyword.put(:url, scheme: "https", host: host, port: 443)
        |> Keyword.put(:secret_key_base, secret)

      {:ok, config}
    else
      {:ok, config}
    end
  end
end
