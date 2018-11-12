defmodule Powerbot.RoonClient do
  @moduledoc """
  Controls Roon by making API calls to
  [st0g1e/roon-extension-http-api](https://github.com/st0g1e/roon-extension-http-api)
  """
  require Logger

  @timeout 1_000

  def list_zones, do: "/listZones" |> url() |> call_url()

  def call(_, nil), do: {:error, "zone_id is nil!"}
  def call(path, zid), do: path |> url(zid) |> call_url()

  defp call_url(url) do
    with {:ok, %Tesla.Env{status: 200, body: body}} <- tesla_get(url) do
      Jason.decode(body)
    end
  end

  defp tesla_get(url) do
    [{Tesla.Middleware.Timeout, timeout: @timeout}]
    |> Tesla.client()
    |> Tesla.get(url)
  end

  defp url("/" <> path, zone_id \\ nil) do
    zid_part = zone_id && "?zoneId=#{zone_id}"
    base_url = Config.roon!(:base_url)
    "#{base_url}/roonAPI/#{path}#{zid_part}"
  end
end
