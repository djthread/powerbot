use Mix.Config

port = String.to_integer(System.get_env("PORT") || "8080")

config :powerbot, PowerbotWeb.Endpoint,
  http: [port: port],
  url: [host: System.get_env("HOSTNAME"), port: port],
  root: "."

config :powerbot, :sparky,
  host: "sparky.threadbox.net",
  delay_shutdown: 8

config :powerbot, :p12, host: "p12.threadbox.net"

config :powerbot, :roon,
  base_url: System.get_env("ROON_BASE_URL" || "https://roon-api"),
  find_zone_delay:
    String.to_integer(System.get_env("ROON_FIND_ZONE_DELAY") || "10"),
  zones: [:dave, :da_dave],
  zone_map: %{
    dave: "1601f06ee3ecdab4007f17fc1f92c20112ff",
    da_dave: "160105d2151b25b726cf541876d70bff6c23"
  }

# Powerbot instance, running on my NAS. This one is important because it is
# able to reach the p12 (PS Audio Power Plant) to issue it commands
config :powerbot, :nas_powerbot,
  base_url: "http://bookshelf.threadbox.net:4000"