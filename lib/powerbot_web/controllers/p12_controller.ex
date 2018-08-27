defmodule PowerbotWeb.P12Controller do
  use PowerbotWeb, :controller
  alias Powerbot.P12

  def status(conn, _) do
    json(conn, P12.status())
  end

  def on(conn, %{"zones" => zones}) do
    zone_list = String.split(zones, ",")
    Task.start(P12, :on, zone_list)
    json(conn, :ok)
  end

  def off(conn, %{"zones" => zones}) do
    zone_list = String.split(zones, ",")
    Task.start(P12, :off, zone_list)
    json(conn, :ok)
  end
end
