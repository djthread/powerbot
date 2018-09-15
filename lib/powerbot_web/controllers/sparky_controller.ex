defmodule PowerbotWeb.SparkyController do
  use PowerbotWeb, :controller

  def poweroff(conn, _params) do
    Task.start(&Powerbot.Sparky.poweroff/0)
    json(conn, :ok)
  end
end
