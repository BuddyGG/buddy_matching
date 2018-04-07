use Mix.Config

config :fortnite_api, fortnite_api_key_client: System.get_env("FORNITE_API_KEY_CLIENT")
config :fortnite_api, fortnite_api_key_launcher: System.get_env("FORNITE_API_KEY_LAUNCHER")
config :fortnite_api, fortnite_api_key_email: System.get_env("FORNITE_API_EMAIL")
config :fortnite_api, fortnite_api_key_password: System.get_env("FORNITE_API_PASSWORD")
config :logger, level: :info
