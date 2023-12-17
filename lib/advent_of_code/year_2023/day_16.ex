defmodule AdventOfCode.Year2023.Day16 do
  @moduledoc """
  Year 2023, Day 16

  https://adventofcode.com/2023/day/16
  """

  def run do
    AdventOfCode.input(2023, 16)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 16, Part 1")

    AdventOfCode.input(2023, 16)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 16, Part 2")
  end

  def solve(input, :first) do
    input
    |> parse_input()
    |> get_powered()
    |> Enum.uniq_by(fn {i, j, _direction} -> {i, j} end)
    |> Enum.count()
  end

  def solve(input, :second) do
    data = parse_input(input)

    max_i = length(input) - 1
    max_j = input |> Enum.at(0) |> String.length() |> Kernel.-(1)

    options = []
    options = Enum.reduce(0..max_i, options, fn i, acc -> [{i, 0, :right} | acc] end)
    options = Enum.reduce(0..max_i, options, fn i, acc -> [{i, max_j, :left} | acc] end)
    options = Enum.reduce(0..max_j, options, fn j, acc -> [{0, j, :down} | acc] end)
    options = Enum.reduce(0..max_j, options, fn j, acc -> [{max_i, j, :up} | acc] end)

    # Not optimized at all, but it works :D
    options
    |> Enum.map(fn start ->
      data
      |> get_powered([start])
      |> Enum.uniq_by(fn {i, j, _direction} -> {i, j} end)
      |> Enum.count()
    end)
    |> Enum.max()
  end

  defp parse_input(input) do
    input = Enum.map(input, &String.graphemes/1)

    max_i = length(input) - 1

    for i <- 0..max_i,
        line = Enum.at(input, i),
        j <- 0..(length(line) - 1),
        element = Enum.at(line, j),
        into: %{} do
      {{i, j}, element}
    end
  end

  defp get_powered(map, to_explore \\ [{0, 0, :right}], acc \\ [])

  defp get_powered(_map, [], acc), do: acc

  defp get_powered(map, [current | others], acc) do
    {i, j, direction} = current

    {next_i, next_j} =
      case direction do
        :up -> {i - 1, j}
        :left -> {i, j - 1}
        :down -> {i + 1, j}
        :right -> {i, j + 1}
      end

    current = Map.get(map, {i, j})

    to_add =
      cond do
        # Avoid loops
        {i, j, direction} in acc -> []
        # If current position does not exist, we are out of the map
        is_nil(current) -> []
        # Empty space
        current == "." -> [{next_i, next_j, direction}]
        # Horizontal tube while going horizontally
        current == "-" and direction in [:left, :right] -> [{next_i, next_j, direction}]
        # Horizontal tube going vertically
        current == "-" -> [{i, j - 1, :left}, {i, j + 1, :right}]
        # Vertical tube while going vertically
        current == "|" and direction in [:up, :down] -> [{next_i, next_j, direction}]
        # Vertical tube while going horizontally
        current == "|" -> [{i - 1, j, :up}, {i + 1, j, :down}]
        # Corners
        current == "/" and direction in [:up] -> [{i, j + 1, :right}]
        current == "/" and direction in [:down] -> [{i, j - 1, :left}]
        current == "/" and direction in [:right] -> [{i - 1, j, :up}]
        current == "/" and direction in [:left] -> [{i + 1, j, :down}]
        current == "\\" and direction in [:up] -> [{i, j - 1, :left}]
        current == "\\" and direction in [:down] -> [{i, j + 1, :right}]
        current == "\\" and direction in [:right] -> [{i + 1, j, :down}]
        current == "\\" and direction in [:left] -> [{i - 1, j, :up}]
      end

    if to_add == [],
      do: get_powered(map, others, acc),
      else: get_powered(map, others ++ to_add, acc ++ [{i, j, direction}])
  end
end
