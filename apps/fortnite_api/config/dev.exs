use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :debug

import_config "dev.secret.exs"
