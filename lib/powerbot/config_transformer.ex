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

  defp maybe_decode_zones_config(str, :zones), do: String.split(str, ",")
  defp maybe_decode_zones_config(str, _), do: str
end
