defmodule AdventOfCode.Year2023.Day8 do
  @moduledoc """
  Year 2023, Day 8

  https://adventofcode.com/2023/day/8
  """

  def run do
    AdventOfCode.input(2023, 8)
    |> AdventOfCode.Year2023.Day8.solve(:first)
    |> IO.inspect(label: "Year 2023, Day 8, Part 1")

    AdventOfCode.input(2023, 8)
    |> AdventOfCode.Year2023.Day8.solve(:second)
    |> IO.inspect(label: "Year 2023, Day 8, Part 2")
  end

  def solve(input, :first) do
    {directions, map} = parse_input(input)
    navigate(directions, map, "AAA")
  end

  def solve(input, :second) do
    {directions, map} = parse_input(input)

    iterations =
      map
      |> Map.keys()
      |> Enum.filter(&String.ends_with?(&1, "A"))
      |> Enum.map(&navigate_ghost(directions, map, &1))

    iterations
    |> Enum.max()
    |> find_mcm(iterations)
  end

  defp parse_input([directions | map]) do
    directions = String.graphemes(directions)

    map =
      map
      |> Enum.map(fn line ->
        [[_, position, left, right]] =
          Regex.scan(~r/^([0-9A-Z]{3}) \= \(([0-9A-Z]{3})\, ([0-9A-Z]{3})\)$/, line)

        {position, [left, right]}
      end)
      |> Enum.into(%{})

    {directions, map}
  end

  defp navigate(turns, map, position, turns_done \\ 0, turns_past \\ [])

  defp navigate([], map, position, turns_done, turns_past),
    do: navigate(turns_past, map, position, turns_done, [])

  defp navigate([turn | other_turns], map, position, turns_done, turns_past) do
    [position_left, position_right] = map[position]

    next_position =
      case turn do
        "L" -> position_left
        "R" -> position_right
      end

    if next_position == "ZZZ",
      do: turns_done + 1,
      else: navigate(other_turns, map, next_position, turns_done + 1, turns_past ++ [turn])
  end

  defp navigate_ghost(turns, map, position, turns_done \\ 0, turns_past \\ [])

  defp navigate_ghost([], map, position, turns_done, turns_past),
    do: navigate_ghost(turns_past, map, position, turns_done, [])

  defp navigate_ghost([turn | other_turns], map, position, turns_done, turns_past) do
    [position_left, position_right] = map[position]

    next_position =
      case turn do
        "L" -> position_left
        "R" -> position_right
      end

    if String.ends_with?(next_position, "Z"),
      do: turns_done + 1,
      else: navigate_ghost(other_turns, map, next_position, turns_done + 1, turns_past ++ [turn])
  end

  defp find_mcm(initial, all_values, step \\ 1) do
    value = initial * step

    if Enum.all?(all_values, &(rem(value, &1) == 0)),
      do: value,
      else: find_mcm(initial, all_values, step + 1)
  end
end
