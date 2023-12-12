defmodule AdventOfCode.Year2023.Day2 do
  @moduledoc """
  Year 2023, Day 2

  https://adventofcode.com/2023/day/2
  """

  @max_cubes [red: 12, green: 13, blue: 14]
  @colors Keyword.keys(@max_cubes)

  def solve_part_1(input) do
    data = parse_input(input)

    data
    |> Enum.filter(fn %{takes: takes} ->
      not Enum.any?(takes, fn take ->
        Enum.any?(take, fn {color, amount} -> amount > @max_cubes[color] end)
      end)
    end)
    |> Enum.reduce(0, fn %{game_number: number}, acc -> acc + number end)
  end

  def solve_part_2(input) do
    data = parse_input(input)

    data
    |> Enum.map(fn %{takes: takes} ->
      cubes_needed =
        takes
        |> Enum.reduce(%{red: 0, blue: 0, green: 0}, fn take, acc ->
          Enum.reduce(@colors, acc, fn color, take_acc ->
            if take[color] && take[color] > take_acc[color],
              do: Map.put(take_acc, color, take[color]),
              else: take_acc
          end)
        end)

      cubes_needed[:red] * cubes_needed[:blue] * cubes_needed[:green]
    end)
    |> Enum.reduce(0, fn power, acc -> acc + power end)
  end

  defp parse_input(input) do
    input
    |> Enum.map(fn line ->
      %{"game" => game_number, "rest" => rest} =
        Regex.named_captures(~r/^Game (?<game>\d+): (?<rest>.*)/, line)

      takes =
        rest
        |> String.split("; ")
        |> Enum.map(fn take ->
          take
          |> String.split(", ")
          |> Enum.map(fn set ->
            set
            |> String.split(" ")
            |> case do
              [number, "red"] -> {:red, String.to_integer(number)}
              [number, "blue"] -> {:blue, String.to_integer(number)}
              [number, "green"] -> {:green, String.to_integer(number)}
            end
          end)
          |> Enum.into(%{})
        end)

      %{game_number: String.to_integer(game_number), takes: takes}
    end)
  end
end

AdventOfCode.input(2023, 2)
|> AdventOfCode.Year2023.Day2.solve_part_1()
|> IO.inspect(label: "Year 2023, Day 2, Part 1")

AdventOfCode.input(2023, 2)
|> AdventOfCode.Year2023.Day2.solve_part_2()
|> IO.inspect(label: "Year 2023, Day 2, Part 1")
