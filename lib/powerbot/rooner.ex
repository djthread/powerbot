defmodule Powerbot.Rooner do
  @moduledoc """
  Tracks the zone_id I want to control.
  """
  alias Powerbot.RoonClient
  require Logger

  defmodule State do
    @moduledoc """
    Rooner state

    * `:base_url` - http/s url for the roon api. No trailing slash.
    * `:zone` - Zone name atom for the active zone
    * `:zone_id` - Zone id string for the active zone
    * `:zones` - Keyword list of zone names as atoms to lists of zone ids as
      strings. I did this because my Dave sometimes randomly shows up as a
      second zone id and I just want to recognize both.
    """
    defstruct ~w(zone zone_id zones base_url)a

    @type t :: %__MODULE__{
            zone: atom,
            zone_id: String.t(),
            zones: keyword([String.t()]),
            base_url: String.t()
          }
  end

  def child_spec(opts) do
    initial_state = state_from_opts!(opts)
    %{id: __MODULE__, start: {__MODULE__, :start_link, [initial_state]}}
  end

  def start_link(state),
    do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def state(key \\ nil) do
    state = GenServer.call(__MODULE__, :state)
    if key, do: Map.get(state, key), else: state
  end

  @doc "Attach to the first zone available"
  def find_zone, do: GenServer.call(__MODULE__, :find_zone)

  @doc "Switch to the next zone"
  def switch, do: GenServer.call(__MODULE__, :switch)

  def play_pause, do: GenServer.call(__MODULE__, {:action, "/play_pause"})

  def next, do: GenServer.call(__MODULE__, {:action, "/next"})

  def previous, do: GenServer.call(__MODULE__, {:action, "/previous"})

  def init(state) do
    Logger.info("State: #{inspect(state)}")

    Process.send_after(self(), :find_zone, 0)
    {:ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:switch, _from, state) do
    state = find_zone(state, after: state.zone)
    ret = %{zone: state.zone, zone_id: state.zone_id}
    {:reply, ret, state}
  end

  def handle_call({:action, path}, _from, state) do
    case RoonClient.call(path, state.zone_id) do
      {:ok, foo} ->
        {:reply, foo, state}

      bad ->
        Logger.debug("Error calling #{path}: #{inspect(bad)}")
        {:reply, :error, state}
    end
  end

  def handle_call(:find_zone, _from, state) do
    state = find_zone(state)
    ret = %{zone: state.zone, zone_id: state.zone_id}
    {:reply, ret, state}
  end

  def handle_info(:find_zone, state) do
    {:noreply, find_zone(state)}
  end

  defp find_zone(%{zone_id: old_zid} = state, opts \\ []) do
    with {:ok, %{"zones" => zones}} <- RoonClient.list_zones(),
         {:ok, {zone, zid}} <- first_present_zone(zones, state.zones, opts) do
      if zid != old_zid, do: Logger.info("Rooner: New zone: #{zone} (#{zid})")
      %{state | zone: zone, zone_id: zid}
    else
      :not_found ->
        state

      {:error, msg} ->
        Logger.error("Rooner.find_zone fail: #{msg}")
        state
    end
  end

  # use option `:after` set to a zone name atom we should ignore.
  defp first_present_zone(found_zones, zones, opts) do
    wanted_zone_ids =
      Enum.reduce(zones, [], fn {zone, ids}, acc ->
        if zone == Keyword.get(opts, :after),
          do: acc,
          else: acc ++ ids
      end)

    Enum.map(found_zones, fn z -> Map.get(z, "zone_id") end)
    |> Enum.filter(fn z -> z in wanted_zone_ids end)
    |> case do
      [zid | _] -> {:ok, {zone_by_id(zones, zid), zid}}
      [] -> :not_found
    end
  end

  defp zone_by_id(zones, zid) do
    case Enum.filter(zones, fn {_name, ids} -> zid in ids end) do
      [{name, _}] -> name
      [] -> nil
    end
  end

  defp state_from_opts!(opts) do
    %State{
      base_url: Keyword.fetch!(opts, :base_url),
      zones: conf_zones!(Keyword.get(opts, :zones, :undefined))
    }
  end

  defp conf_zones!(z) when byte_size(z) > 0, do: decode_zones_config(z)
  defp conf_zones!(z) when is_list(z), do: z
  defp conf_zones!(z), do: raise(ArgumentError, "Bad zones: #{inspect(z)}")

  # iex> decode_map_of_lists("a:[123,456];b:[789]")
  # [a: ["123", "456"], b: ["789"]]
  @spec decode_zones_config(String.t()) :: keyword([String.t()])
  defp decode_zones_config(str) do
    Enum.reduce(String.split(str, ";"), [], fn part, acc ->
      [k, list_str] = String.split(part, ":")

      list =
        list_str
        |> String.trim_leading("[")
        |> String.trim_trailing("]")
        |> String.split(",")
        |> Enum.map(&String.to_atom/1)

      [{String.to_atom(k), list} | acc]
    end)
    |> Enum.reverse()
  end
end
