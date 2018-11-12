defmodule Powerbot.RoonClient do
  @moduledoc """
  Controls Roon by making API calls to
  [st0g1e/roon-extension-http-api](https://github.com/st0g1e/roon-extension-http-api)
  """
  alias Powerbot.Rooner

  def list_zones do
    url = url("/listZones")

    with {:ok, env} <- Tesla.get(url),
         %{status: 200, body: body} <- env do
      Jason.decode(body)
    else
      bad -> {:error, "Bad news calling #{url}: #{inspect(bad)}"}
    end
  end

  def play_pause(zid \\ nil),
    do: do_call("/play_pause", zid)

  def next(zid \\ nil),
    do: do_call("/next", zid)

  def previous(zid \\ nil),
    do: do_call("/previous", zid)

  defp do_call(path, zid) do
    zid = if zid, do: zid, else: Rooner.state(:zone_id)

    {:ok, %Tesla.Env{status: 200, body: body}} =
      path |> url(zid) |> Tesla.get()

    Jason.decode(body)
  end

  defp url("/" <> path, zone_id \\ nil) do
    zid_part = zone_id && "?zoneId=#{zone_id}"
    base_url = Config.roon!(:base_url)
    "#{base_url}/roonAPI/#{path}#{zid_part}"
  end
end
