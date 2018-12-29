defmodule Powerbot.Rooner do
  @moduledoc """
  Tracks the zone I want to control.
  """
  alias Powerbot.RoonClient
  require Logger

  defmodule State do
    @moduledoc """
    Rooner state

    * `:base_url` - http/s url for the roon api. No trailing slash.
    * `:zone` - Zone display name string for the active zone
    * `:zone_id` - Zone id string for the active zone
    * `:wanted_zone_names` - List of strings corresponding to the display names
      for the zones we are interested in toggling between.
    """
    defstruct ~w(zone zone_id wanted_zone_names base_url)a

    @type t :: %__MODULE__{
            base_url: String.t(),
            zone: String.t(),
            zone_id: String.t(),
            wanted_zone_names: [String.t()],
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
        Logger.debug(fn -> "Error calling #{path}: #{inspect(bad)}" end)
        {:reply, :error, state}
    end
  end

  def handle_call(:find_zone, _from, state) do
    state = find_zone(state)
    ret = %{zone: state.zone, zone_name: state.zone_name}
    {:reply, ret, state}
  end

  def handle_info(:find_zone, state) do
    {:noreply, find_zone(state)}
  end

  defp find_zone(%{zone_id: old_zid} = state, opts \\ []) do
    with {:ok, %{"zones" => zones}} <- RoonClient.list_zones(),
         {:ok, {zone, zid}} <- first_present_zone(zones, state.wanted_zone_names, opts) do
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
  defp first_present_zone(found_zones, wanted_zone_names, opts) do
    wanted_zone_names =
      case Keyword.fetch(opts, :after) do
        {:ok, bye} -> Enum.reject(wanted_zone_names, &(&1 == bye))
        :error -> wanted_zone_names
      end

    found_zones
    |> Enum.map(fn z ->
      id = Map.get(z, "zone_id")
      name = Map.get(z, "display_name")
      {name, id}
    end)
    |> Enum.filter(fn {z, _} -> z in wanted_zone_names end)
    |> case do
      [{name, zid} | _] -> {:ok, {name, zid}}
      [] -> :not_found
    end
  end

  defp state_from_opts!(opts) do
    %State{
      base_url: Keyword.fetch!(opts, :base_url),
      wanted_zone_names: Keyword.fetch!(opts, :zones)
    }
  end
end
