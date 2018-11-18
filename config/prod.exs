use Mix.Config

config :powerbot, PowerbotWeb.Endpoint,
  # http: [:inet6, port: System.get_env("PORT") || 4000],
  # url: [host: "localhost", port: 80],
  # load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# url: [host: "example.com", port: 80],
# cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info
