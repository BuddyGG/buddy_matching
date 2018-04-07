use Mix.Config

config :fortnite_api, fortnite_api_key_client: System.get_env("FORNITE_API_KEY_CLIENT")
config :fortnite_api, fortnite_api_key_launcher: System.get_env("FORNITE_API_KEY_LAUNCHER")
config :logger, level: :info
