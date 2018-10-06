defmodule Powerbot.Rooner do
  @moduledoc """
  Tracks the zone_id I want to control.
  """
  alias Powerbot.RoonClient
  require Logger

  @initial_state %{zone: nil}

  def child_spec([]) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [@initial_state]}}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def zone_id do
    GenServer.call(__MODULE__, :zone_id)
  end

  def init(state) do
    Logger.info("""
    Zones: #{inspect(Config.roon!(:zones))}
    Zone Map: #{inspect(Config.roon!(:zone_map))}
    Find Zone Delay: #{inspect(Config.roon!(:find_zone_delay))}
    Base URL: #{inspect(Config.roon!(:base_url))}
    """)

    Process.send_after(self(), :find_zone, 0)
    {:ok, state}
  end

  def handle_call(:zone_id, _from, %{zone: zone} = state) do
    {:reply, Config.roon!(:zone_map)[zone], state}
  end

  def handle_info(:find_zone, %{zone: old_zone} = state) do
    new_zone = find_zone()
    state = Map.put(state, :zone, new_zone)

    if new_zone != old_zone,
      do: Logger.info("Rooner: New zone: #{new_zone}")

    delay = Config.roon!(:find_zone_delay) * 1_000
    Process.send_after(self(), :find_zone, delay)

    {:noreply, state}
  end

  defp find_zone do
    with {:ok, %{"zones" => zones}} <- RoonClient.list_zones(),
         wanted_zones <- Config.roon!(:zones),
         {:ok, zone} <- first_present_zone(zones, wanted_zones) do
      zone
    else
      :not_found ->
        nil

      {:error, msg} ->
        Logger.error("Rooner.find_zone fail: #{msg}")
        nil
    end
  end

  defp first_present_zone(zones, [to_find | rest]) do
    zone_map = Config.roon!(:zone_map)

    zones
    |> Enum.filter(fn z ->
      Map.get(z, "zone_id") == zone_map[to_find]
    end)
    |> case do
      [_] -> {:ok, to_find}
      [] -> first_present_zone(zones, rest)
    end
  end

  defp first_present_zone(_, []) do
    :not_found
  end
end
