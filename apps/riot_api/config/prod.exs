use Mix.Config

config :riot_api, riot_api_key: System.get_env("RIOT_API_KEY")
config :logger, level: :info
