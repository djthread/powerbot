defmodule Powerbot.ConfigTransformer do
  @moduledoc "Config transformer for Toml.Provider via Distillery"

  @doc false
  def transform(key, str) when is_binary(str) do
    str
    |> resolve_env_vars()
    |> maybe_decode_zones_config(key)
  end

  def transform(_k, map) when is_map(map) do
    Enum.into(map, [])
  end

  def transform(_k, v), do: v

  defp resolve_env_vars(str) do
    Regex.replace(~r/\${([A-Z0-9_]+)}/, str, fn _, v ->
      System.get_env(v) || ""
    end)
  end

  defp maybe_decode_zones_config(str, :zones), do: decode_zones_config(str)
  defp maybe_decode_zones_config(str, _), do: str

  # iex> decode_map_of_lists("a:[123,456];b:[789]")
  # [a: ["123", "456"], b: ["789"]]
  @spec decode_zones_config(String.t()) :: keyword([String.t()])
  defp decode_zones_config(str) do
    str
    |> String.split(";")
    |> Enum.reduce([], fn part, acc ->
      [k, list_str] = String.split(part, ":")

      list =
        list_str
        |> String.trim_leading("[")
        |> String.trim_trailing("]")
        |> String.split(",")

      [{String.to_atom(k), list} | acc]
    end)
    |> Enum.reverse()
  end
end
