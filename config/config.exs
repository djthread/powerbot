# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :powerbot, PowerbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "+mWFWrge2zAXRElgTwA/imYwc/6X84OyTAseIyIrAtMumpkU0znfjFB3+5eLd0rT",
  render_errors: [view: PowerbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Powerbot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :powerbot, :sparky,
  host: "sparky.threadbox.net",
  delay_shutdown: 5

config :powerbot, :p12, host: "p12.threadbox.net"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
