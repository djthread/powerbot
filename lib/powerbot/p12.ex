defmodule Powerbot.P12 do
  @moduledoc "For controlling my PS Audio DirectStream Power Plant 12"

  @host Config.p12!(:host)
  @toggle_path "/zones.cgi?zone="

  require Logger

  defmodule Status do
    defstruct ~w(power zone1 zone2 zone3 zone4)a
  end

  def status do
    "/status.xml"
    |> get()
    |> status_from_xml()
  end

  def off(zones) when is_list(zones) do
    do_toggler(zones, fn
      z, true -> get(@toggle_path <> to_string(z))
      z, false -> Logger.warn("Zone #{z} already off!")
      z, nil -> Logger.error("Wth is zone #{z}¿")
    end)
  end
  def off(z), do: off([z])

  def on(zones) when is_list(zones) do
    do_toggler(zones, fn
      z, true -> Logger.warn("Zone #{z} already on!")
      z, false -> get(@toggle_path <> to_string(z))
      z, nil -> Logger.error("Wth is zone #{z}¿")
    end)
  end
  def on(z), do: on([z])

  def do_toggler(zones, fun) do
    status = status()

    Enum.each(zones, fn z ->
      fun.(z, Map.get(status, z_to_a(z)))
    end)
  end

  defp z_to_a(1), do: :zone1
  defp z_to_a(2), do: :zone2
  defp z_to_a(3), do: :zone3
  defp z_to_a(4), do: :zone4

  defp status_from_xml(xml) do
    Status
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce(%Status{}, fn k, acc ->
      [_, st] = Regex.run(~r/<#{k}>(1|0)/, xml)
      Map.put(acc, k, st == "1")
    end)
  end

  defp get(path) do
    case Tesla.get(url(path)) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> body
      bad -> raise "P12 GET fail: #{inspect(bad)}"
    end
  end

  defp url(path), do: "http://#{@host}#{path}"
end