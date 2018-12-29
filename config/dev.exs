use Mix.Config

config :powerbot, PowerbotWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :powerbot, PowerbotWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/powerbot_web/views/.*(ex)$},
      ~r{lib/powerbot_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :powerbot, :roon,
  zones: [
    "M Scaler",
    "Autechre"
    # mscaler: [
    #   "160144202585d433f26a4826ba2797b157cf"
    # ],
    # # dave: [
    # #   "1601f06ee3ecdab4007f17fc1f92c20112ff",
    # #   "160105d2151b25b726cf541876d70bff6c23"
    # # ],
    # autechre: ["1601cada42df00f0879bd9619519205719f4"]
  ]
