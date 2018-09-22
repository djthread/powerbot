defmodule Powerbot.Rooner do
  @moduledoc """
  Tracks the zone_id I want to control.
  """
  alias Powerbot.RoonClient
  require Logger

  @zones Config.roon!(:zones)
  @zone_map Config.roon!(:zone_map)
  @find_zone_delay Config.roon(:find_zone_delay)
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
    Process.send_after(self(), :find_zone, 0)
    {:ok, state}
  end

  def handle_call(:zone_id, _from, %{zone: zone} = state) do
    {:reply, @zone_map[zone], state}
  end

  def handle_info(:find_zone, %{zone: old_zone} = state) do
    new_zone = find_zone()
    state = Map.put(state, :zone, new_zone)

    if new_zone != old_zone,
      do: Logger.info("Rooner: New zone: #{new_zone}")

    Process.send_after(self(), :find_zone, @find_zone_delay * 1_000)

    {:noreply, state}
  end

  defp find_zone do
    with {:ok, %{"zones" => zones}} <- RoonClient.list_zones(),
         {:ok, zone} <- first_present_zone(zones, @zones) do
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
    zones
    |> Enum.filter(fn z ->
      Map.get(z, "zone_id") == @zone_map[to_find]
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
