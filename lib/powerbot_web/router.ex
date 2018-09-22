defmodule PowerbotWeb.Router do
  use PowerbotWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # scope "/", PowerbotWeb do
  #   pipe_through :browser # Use the default browser stack

  #   get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/api", PowerbotWeb do
    pipe_through :api

    scope "/system" do
      post "/on", SystemController, :on
      post "/off", SystemController, :off
    end

    scope "/p12" do
      get "/status", P12Controller, :status
      post "/on/:zones", P12Controller, :on
      post "/off/:zones", P12Controller, :off
    end

    scope "/sparky" do
      post "/poweroff", SparkyController, :poweroff
    end

    scope "/roon" do
      post "/zone", RoonController, :zone
      post "/play-pause", RoonController, :play_pause
      post "/next", RoonController, :next
      post "/previous", RoonController, :previous
    end
  end
end
