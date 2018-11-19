use Mix.Config

config :powerbot, PowerbotWeb.Endpoint,
  secret_key_base:
    "+mWFWrge2zAXRElgTwA/imYwc/6X84OyTAseIyIrAtMumpkU0znfjFB3+5eLd0rT",
  render_errors: [view: PowerbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Powerbot.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

config :powerbot, :p12, host: "p12.threadbox.net"

config :powerbot, :roon, base_url: "https://roon-api"

config :powerbot, :sparky,
  host: "sparky.threadbox.net",
  delay_shutdown: 8

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Powerbot instance, running on my NAS. This one is important because it is
# able to reach the p12 (PS Audio Power Plant) to issue it commands
config :powerbot, :nas_powerbot, base_url: "http://bookshelf.threadbox.net:4000"

import_config "#{Mix.env()}.exs"
