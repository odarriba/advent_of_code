defmodule AdventOfCode.Year2023.Day9 do
  @moduledoc """
  Year 2023, Day 9

  https://adventofcode.com/2023/day/9
  """

  def run do
    AdventOfCode.input(2023, 9)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 9, Part 1")

    AdventOfCode.input(2023, 9)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 9, Part 2")
  end

  def solve(input, :first) do
    input
    |> parse_input()
    |> Enum.map(fn serie ->
      [serie]
      |> calculate_diff()
      |> get_new_value()
    end)
    |> Enum.sum()
  end

  def solve(input, :second) do
    input
    |> parse_input()
    |> Enum.map(fn serie ->
      [serie]
      |> calculate_diff()
      |> get_old_value()
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    Enum.map(input, fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp calculate_diff([serie | _] = series) do
    if Enum.all?(serie, &(&1 == 0)) do
      series
    else
      new_serie =
        Enum.reduce(1..(length(serie) - 1), [], fn index, acc ->
          diff = Enum.at(serie, index) - Enum.at(serie, index - 1)
          acc ++ [diff]
        end)

      calculate_diff([new_serie | series])
    end
  end

  defp get_new_value(series, last_value \\ 0)
  defp get_new_value([], last_value), do: last_value

  defp get_new_value([serie | rest], last_value),
    do: get_new_value(rest, last_value + List.last(serie))

  defp get_old_value(series, last_value \\ 0)
  defp get_old_value([], last_value), do: last_value
  defp get_old_value([serie | rest], last_value), do: get_old_value(rest, hd(serie) - last_value)
end
