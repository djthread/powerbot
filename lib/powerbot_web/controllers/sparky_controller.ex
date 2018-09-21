defmodule PowerbotWeb.SparkyController do
  use PowerbotWeb, :controller
  alias Powerbot.Sparky

  def poweroff(conn, _params) do
    Task.start(&Sparky.poweroff/0)
    json(conn, :ok)
  end
end
