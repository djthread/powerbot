defmodule PowerbotWeb.Router do
  use PowerbotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", PowerbotWeb do
  #   pipe_through :browser # Use the default browser stack

  #   get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/api", PowerbotWeb do
    pipe_through :api

    scope "/sparky" do
      post "/shutdown", SparkyController, :shutdown
    end
  end
end
