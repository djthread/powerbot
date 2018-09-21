defmodule Powerbot.RoonClient do
  @moduledoc """
  Controls Roon by making API calls to
  [st0g1e/roon-extension-http-api](https://github.com/st0g1e/roon-extension-http-api)
  """

  @base_url Config.roon!(:base_url)

  def list_zones do
    with {:ok, env} <- "/listZones" |> url() |> Tesla.get(),
         %{status: 200, body: body} <- env do
      Jason.decode(body)
    end
  end

  defp url("/" <> path) do
    "#{@base_url}/roonAPI/#{path}"
  end
end
