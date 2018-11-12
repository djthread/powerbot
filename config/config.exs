use Mix.Config

config :powerbot, PowerbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "+mWFWrge2zAXRElgTwA/imYwc/6X84OyTAseIyIrAtMumpkU0znfjFB3+5eLd0rT",
  render_errors: [view: PowerbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Powerbot.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

import_config "#{Mix.env()}.exs"
