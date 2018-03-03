# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :lol_buddy, LolBuddyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NXkm0vlBsJMoq0c5tOwIE7PoxtCRx6C9cvpbgdPE8wZc7Wej2BELkzWIN0Kd6+tw",
  render_errors: [view: LolBuddyWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LolBuddy.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :pre_commit,
  commands: ["test", "format", "credo"],
  verbose: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
