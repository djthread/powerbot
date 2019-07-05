defmodule PowerbotWeb.P12Controller do
  use PowerbotWeb, :controller
  alias Powerbot.P12

  def status(conn, _) do
    json(conn, P12.status())
  end

  def query(conn, %{"zone" => zone}) do
    status = P12.status()

    state =
      case zone do
        "power" -> status.power
        "1" -> status.zone1
        "2" -> status.zone1
        "3" -> status.zone1
        "4" -> status.zone1
      end

    if not state do
      raise "The zone is off. Crashing to make non-zero exit codes."
    end

    json(conn, :ok)
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
