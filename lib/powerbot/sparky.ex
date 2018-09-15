defmodule Powerbot.Sparky do
  @moduledoc "For controlling my sparky"

  @host Config.sparky!(:host)

  def poweroff do
    sudo("poweroff")
  end

  defp sudo(cmd) when is_binary(cmd) do
    args = [
      "root@#{@host}",
      "-o", "UserKnownHostsFile=/dev/null",
      "-o", "StrictHostKeyChecking=no"
    ]

    System.cmd("ssh", args ++ [cmd])
  end
end
