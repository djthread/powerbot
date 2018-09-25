use Mix.Config

config :powerbot, PowerbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "+mWFWrge2zAXRElgTwA/imYwc/6X84OyTAseIyIrAtMumpkU0znfjFB3+5eLd0rT",
  render_errors: [view: PowerbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Powerbot.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :powerbot, :sparky,
  host: "sparky.threadbox.net",
  delay_shutdown: 8

config :powerbot, :p12, host: "p12.threadbox.net"

config :powerbot, :roon,
  base_url: "http://localhost:3001",
  find_zone_delay: 10,
  zones: [:dave, :da_dave],
  zone_map: %{
    dave: "1601f06ee3ecdab4007f17fc1f92c20112ff",
    da_dave: "160105d2151b25b726cf541876d70bff6c23"
  }

# Powerbot instance, running on my NAS. This one is important because it is
# ablse to reach the p12 (PS Audio Power Plant) to issue it commands
config :powerbot, :nas_powerbot,
  base_url: "http://bookshelf.threadbox.net:4000"

import_config "#{Mix.env()}.exs"
