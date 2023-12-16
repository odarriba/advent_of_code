defmodule AdventOfCode.Year2023.Day14 do
  @moduledoc """
  Year 2023, Day 14

  https://adventofcode.com/2023/day/14
  """

  def run do
    AdventOfCode.input(2023, 14)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 14, Part 1")

    # This takes some time (less than two minutes)
    AdventOfCode.input(2023, 14)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 14, Part 2")
  end

  def solve(input, :first) do
    {data, raw_map} = parse_input(input)

    data
    |> roll(:north, raw_map)
    |> calculate_weight(raw_map)
  end

  def solve(input, :second) do
    {data, raw_map} = parse_input(input)

    data
    |> calculate_cycles(1_000_000_000, raw_map)
    |> calculate_weight(raw_map)
  end

  defp parse_input(input) do
    raw_map = Enum.map(input, &String.graphemes/1)
    max_i = length(raw_map) - 1

    data =
      Enum.reduce(0..max_i, {[], []}, fn i, acc ->
        line = Enum.at(raw_map, i)
        max_j = length(line) - 1

        Enum.reduce(0..max_j, acc, fn j, {acc_round, acc_square} ->
          case Enum.at(line, j) do
            "O" -> {[{i, j} | acc_round], acc_square}
            "#" -> {acc_round, [{i, j} | acc_square]}
            "." -> {acc_round, acc_square}
          end
        end)
      end)

    {data, raw_map}
  end

  defp calculate_cycles(input, remaining_cycles, raw_map),
    do: calculate_cycles(input, remaining_cycles, raw_map, remaining_cycles)

  # Last cycle!
  defp calculate_cycles(input, 1, _raw_map, _total_iterations), do: input

  defp calculate_cycles(input, remaining_cycles, raw_map, total_iterations) do
    result =
      input
      |> roll(:north, raw_map)
      |> roll(:west, raw_map)
      |> roll(:south, raw_map)
      |> roll(:east, raw_map)

    cached_idx = Process.get(result)
    current_iteration = total_iterations - remaining_cycles

    # If we detected a loop of `i - cached_idx` elements, we calculate
    # the maximum number of loops we can skip to avoid surpassing the
    # limit and we calculate manually the rest of them.
    remaining =
      if cached_idx do
        calculate_rem = rem(remaining_cycles, current_iteration - cached_idx)

        # In some cases the remaining cycles after the skip is the same
        # as we have without using the cache. That's because we have only
        # a few left and we have to just continue calculating.
        if calculate_rem == remaining_cycles,
          do: remaining_cycles - 1,
          else: calculate_rem
      else
        Process.put(result, current_iteration)
        remaining_cycles - 1
      end

    calculate_cycles(result, remaining, raw_map, total_iterations)
  end

  defp roll({rounded, square}, direction, raw_map) do
    case direction do
      :north -> move_vertically({rounded, square}, :up, raw_map)
      :south -> move_vertically({rounded, square}, :down, raw_map)
      :east -> move_horizontally({rounded, square}, :left, raw_map)
      :west -> move_horizontally({rounded, square}, :right, raw_map)
    end
  end

  defp move_vertically({rounded, square}, direction, raw_map) do
    # Need to sort by the vertical axis to ensure we roll them accordingly.
    sort_direction = if direction == :up, do: :asc, else: :desc
    rounded = Enum.sort_by(rounded, &elem(&1, 0), sort_direction)

    max_i = length(raw_map) - 1

    rounded =
      Enum.reduce(rounded, [], fn {i, j}, acc ->
        possible_positions =
          if direction == :up,
            do: i..0,
            else: i..max_i

        new_i =
          Enum.find(possible_positions, fn possible_i ->
            next_position =
              if direction == :up,
                do: possible_i - 1,
                else: possible_i + 1

            cond do
              # Out of the map
              next_position < 0 or next_position > max_i -> true
              # Found a square rock
              {next_position, j} in square -> true
              # Already a rock there
              {next_position, j} in acc -> true
              # No obstable, continue finding the best position
              true -> false
            end
          end)

        [{new_i, j} | acc]
      end)
      |> Enum.reverse()

    {rounded, square}
  end

  defp move_horizontally({rounded, square}, direction, raw_map) do
    # Need to sort by the vertical axis to ensure we roll them accordingly.
    sort_direction = if direction == :right, do: :asc, else: :desc
    rounded = Enum.sort_by(rounded, &elem(&1, 1), sort_direction)

    max_j = length(Enum.at(raw_map, 0)) - 1

    rounded =
      Enum.reduce(rounded, [], fn {i, j}, acc ->
        possible_positions =
          if direction == :right,
            do: j..0,
            else: j..max_j

        new_j =
          Enum.find(possible_positions, fn possible_j ->
            next_position =
              if direction == :right,
                do: possible_j - 1,
                else: possible_j + 1

            cond do
              # Out of the map
              next_position < 0 or next_position > max_j -> true
              # Found a square rock
              {i, next_position} in square -> true
              # Already a rock there
              {i, next_position} in acc -> true
              # No obstable, continue finding the best position
              true -> false
            end
          end)

        [{i, new_j} | acc]
      end)
      |> Enum.reverse()

    {rounded, square}
  end

  defp calculate_weight({rounded, _}, raw_map) do
    max_value = length(raw_map)

    Enum.reduce(rounded, 0, fn {i, _j}, acc ->
      value = max_value - i
      acc + value
    end)
  end
end
