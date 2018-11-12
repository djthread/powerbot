defmodule Powerbot.Application do
  @moduledoc false
  use Application
  alias PowerbotWeb.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Powerbot.Rooner, Application.get_env(:powerbot, :roon)},
      Endpoint
    ]

    opts = [strategy: :one_for_one, name: Powerbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
