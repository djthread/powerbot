defmodule PowerbotWeb.RoonController do
  @moduledoc "Control Roon!"

  use PowerbotWeb, :controller
  alias Powerbot.{Rooner, RoonClient}

  def zone(conn, _) do
    {:ok, ret} = Rooner.zone_id()
    json(conn, ret)
  end

  def play_pause(conn, _) do
    {:ok, ret} = RoonClient.play_pause()
    json(conn, ret)
  end

  def next(conn, _) do
    {:ok, ret} = RoonClient.next()
    json(conn, ret)
  end

  def previous(conn, _) do
    {:ok, ret} = RoonClient.previous()
    json(conn, ret)
  end
end
