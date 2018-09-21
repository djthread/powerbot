defmodule PowerbotWeb.SystemController do
  use PowerbotWeb, :controller
  alias Powerbot.{P12, Sparky}

  @delay_shutdown Config.sparky!(:delay_shutdown)

  def off(conn, _params) do
    Task.start(fn ->
      Sparky.poweroff()
      :timer.sleep(@delay_shutdown * 1_000)
      P12.off(0)
    end)

    json(conn, :ok)
  end

  def on(conn, _params) do
    Task.start(fn ->
      P12.on(0)
    end)

    json(conn, :ok)
  end
end
