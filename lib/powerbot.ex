defmodule Powerbot do
  @moduledoc """
  Powerbot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
    iex> Powerbot.decode_map_of_lists("a:[x,y];b:[m]")
    %{a: [:x, :y], b: [:m]}
  """
  def decode_map_of_lists(str) do
    Enum.reduce(String.split(str, ";"), %{}, fn part, acc ->
      [k, list_str] = String.split(part, ":")

      list =
        list_str
        |> String.trim_leading("[")
        |> String.trim_trailing("]")
        |> String.split(",")
        |> Enum.map(&String.to_atom/1)

      Map.put(acc, String.to_atom(k), list)
    end)
  end

  @doc """
    iex> Powerbot.decode_map("a:1,b:2,c:3")
    %{a: "1", b: "2", c: "3"}
  """
  def decode_map(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [k, v] -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end
end
