defmodule Powerbot.RoonClient do
  @moduledoc """
  Controls Roon by making API calls to
  [st0g1e/roon-extension-http-api](https://github.com/st0g1e/roon-extension-http-api)
  """
  alias Powerbot.Rooner

  @base_url Config.roon!(:base_url)
  @zone_map Config.roon!(:zone_map)

  def list_zones do
    with {:ok, env} <- "/listZones" |> url() |> Tesla.get(),
         %{status: 200, body: body} <- env do
      Jason.decode(body)
    else
      bad -> {:error, "Bad news: #{inspect(bad)}"}
    end
  end

  def play_pause(zone \\ nil),
    do: do_call("/play_pause", zone)

  def next(zone \\ nil),
    do: do_call("/next", zone)

  def previous(zone \\ nil),
    do: do_call("/previous", zone)

  defp do_call(path, zone) do
    zid = zone_id(zone)

    {:ok, %Tesla.Env{status: 200, body: body}} =
      path |> url(zid) |> Tesla.get()

    Jason.decode(body)
  end

  defp zone_id(nil), do: Rooner.zone_id()
  defp zone_id(z), do: Map.fetch!(@zone_map, z)

  defp url("/" <> path, zone_id \\ nil) do
    zid_part = zone_id && "?zoneId=#{zone_id}"
    "#{@base_url}/roonAPI/#{path}#{zid_part}"
  end
end
