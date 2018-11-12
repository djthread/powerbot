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
    # find_zone_delay
    # * `:default_zone` - Zone name as atom to use as default

    @type t :: %__MODULE__{
            zone: atom,
            zone_id: String.t,
            zones: keyword([String.t()]),
            # find_zone_delay: integer,
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
    if key, do: state[key], else: state
  end

  def init(state) do
    Logger.info("State: #{inspect(state)}")

    Process.send_after(self(), :find_zone, 0)
    {:ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:find_zone, %{zone_id: old_zid} = state) do
    %{zone_id: zid} = state = find_zone(state)

    if zid != old_zid, do: Logger.info("Rooner: New zone: #{zid}")

    # Process.send_after(self(), :find_zone, state.find_zone_delay * 1_000)

    {:noreply, state}
  end

  defp find_zone(state) do
    with {:ok, %{"zones" => zones}} <- RoonClient.list_zones(),
         {:ok, {name, id}} <- first_present_zone(zones, state.zones) do
      %{state | zone: name, zone_id: id}
    else
      :not_found ->
        state

      {:error, msg} ->
        Logger.error("Rooner.find_zone fail: #{msg}")
        state
    end
  end

  defp first_present_zone(found_zones, wanted_zones)

  defp first_present_zone(zones, [{zone, ids} | rest]) do
    Enum.map(zones, fn z -> Map.get(z, "zone_id") end)
    |> Enum.filter(fn z -> z in ids end)
    |> case do
      [zid] -> {:ok, {zone, zid}}
      [] -> first_present_zone(zones, rest)
    end
  end

  defp first_present_zone(_, []) do
    :not_found
  end

  defp state_from_opts!(opts) do
    %State{
      base_url: Keyword.fetch!(opts, :base_url),
      zones: conf_zones!(Keyword.get(opts, :zones, :undefined)),
      # find_zone_delay:
      #   conf_find_zone_delay!(Keyword.get(opts, :find_zone_delay, 10)),
    }
  end

  # defp conf_find_zone_delay!(d) when d > 0, do: d

  # defp conf_find_zone_delay!(d) when byte_size(d) > 0 do
  #   {del, ""} = Integer.parse(d)
  #   del
  # end

  # defp conf_find_zone_delay!(d),
  #   do: raise(ArgumentError, "Bad find_zone_delay: #{inspect(d)}")

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
