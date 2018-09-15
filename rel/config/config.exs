use Mix.Config

port = String.to_integer(System.get_env("PORT") || "8080")

config :powerbot, PowerbotWeb.Endpoint,
  http: [port: port],
  url: [host: System.get_env("HOSTNAME"), port: port],
  root: "."
