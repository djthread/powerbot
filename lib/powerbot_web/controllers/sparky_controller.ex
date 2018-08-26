defmodule PowerbotWeb.SparkyController do
  use PowerbotWeb, :controller

  def shutdown(conn, _params) do
    Task.start(&Powerbot.Sparky.shutdown/0)
    json(conn, :ok)
  end
end
