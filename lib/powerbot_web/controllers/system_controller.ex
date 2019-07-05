defmodule PowerbotWeb.SystemController do
  use PowerbotWeb, :controller
  alias Powerbot.{P12, Sparky}

  @audio_zones [1, 3, 4]

  @doc """
  Shut down Sparky, then turn off audio zones 1, 3, and 4.
  """
  def audio_off(conn, _params) do
    Task.start(fn ->
      Sparky.poweroff()
      :timer.sleep(Config.sparky!(:delay_shutdown) * 1_000)
      P12.off(@audio_zones)
    end)

    json(conn, :ok)
  end

  @doc """
  Turn on audio zones 1, 3, and 4.
  """
  def audio_on(conn, _params) do
    Task.start(fn ->
      P12.on(@audio_zones)
    end)

    json(conn, :ok)
  end

  def off(conn, _params) do
    Task.start(fn ->
      Sparky.poweroff()
      :timer.sleep(Config.sparky!(:delay_shutdown) * 1_000)
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
