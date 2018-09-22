defmodule PowerbotWeb.RoonController do
  @moduledoc "Control Roon!"

  use PowerbotWeb, :controller
  alias Powerbot.RoonClient

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
