defmodule PowerbotWeb.RoonController do
  @moduledoc "Control Roon!"

  use PowerbotWeb, :controller
  alias Powerbot.Rooner

  def zone(conn, _) do
    state = Rooner.state()
    ret = %{zone: state.zone, zone_id: state.zone_id}
    json(conn, ret)
  end

  def switch(conn, _) do
    ret = Rooner.switch()
    json(conn, ret)
  end

  def play_pause(conn, _) do
    ret = Rooner.play_pause()
    json(conn, ret)
  end

  def next(conn, _) do
    ret = Rooner.next()
    json(conn, ret)
  end

  def previous(conn, _) do
    ret = Rooner.previous()
    json(conn, ret)
  end
end
