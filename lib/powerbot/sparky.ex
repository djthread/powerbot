defmodule Powerbot.Sparky do
  @moduledoc "For controlling my sparky"

  @host Config.sparky!(:host)
  @delay_shutdown Config.sparky!(:delay_shutdown)

  alias Powerbot.P12

  def shutdown do
    sudo("poweroff")

    :timer.sleep(@delay_shutdown * 1_000)

    P12.off([1, 4])
  end

  defp sudo(cmd) when is_binary(cmd) do
    args = [
      "root@#{@host}",
      "-o",
      "UserKnownHostsFile=/dev/null",
      "-o",
      "StrictHostKeyChecking=no"
    ]

    System.cmd("ssh", args ++ [cmd])
  end
end
