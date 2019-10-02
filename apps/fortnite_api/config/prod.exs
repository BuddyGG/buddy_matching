use Mix.Config

config :fortnite_api, fortnite_api_key: System.get_env("FORTNITE_API_KEY")
config :fortnite_api, fortnite_api_email: System.get_env("FORTNITE_API_EMAIL")
config :fortnite_api, fortnite_api_password: System.get_env("FORTNITE_API_PASSWORD")
config :logger, level: :info
