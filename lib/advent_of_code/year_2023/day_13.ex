defmodule AdventOfCode.Year2023.Day13 do
  @moduledoc """
  Year 2023, Day 13

  https://adventofcode.com/2023/day/13
  """

  def run do
    AdventOfCode.raw_input(2023, 13)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 13, Part 1")

    AdventOfCode.raw_input(2023, 13)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 13, Part 2")
  end

  def solve(input, part) do
    smudge =
      case part do
        :first -> false
        :second -> true
      end

    input
    |> parse_input()
    |> Enum.map(&find_reflections(&1, smudge))
    |> Enum.reduce(0, fn
      {num, :vertical}, acc -> acc + num
      {num, :horizontal}, acc -> acc + num * 100
    end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn map ->
      map
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
    end)
  end

  defp find_reflections(map, true),
    do:
      find_reflections(map, true, :vertical) || find_reflections(map, true, :horizontal) ||
        find_reflections(map, false)

  defp find_reflections(map, false),
    do: find_reflections(map, false, :vertical) || find_reflections(map, false, :horizontal)

  defp find_reflections(map, smudges, :vertical) do
    first_row = hd(map)
    num_columns = length(first_row)

    posible_reflection_groups =
      Enum.map(1..(num_columns - 1), fn idx ->
        columns_left = idx
        columns_right = num_columns - idx

        columns_to_compare = min(columns_left, columns_right)

        group_left =
          Enum.map(map, &Enum.slice(&1, idx - columns_to_compare, columns_to_compare))

        group_right =
          Enum.map(map, fn row ->
            row
            |> Enum.slice(idx, columns_to_compare)
            |> Enum.reverse()
          end)

        {idx, group_left, group_right}
      end)

    case find_reflection_index(posible_reflection_groups, smudges) do
      {index, _, _} -> {index, :vertical}
      _ -> nil
    end
  end

  defp find_reflections(map, smudges, :horizontal) do
    num_rows = length(map)

    posible_reflection_groups =
      Enum.map(1..(num_rows - 1), fn idx ->
        rows_left = idx
        rows_right = num_rows - idx
        rows_to_compare = min(rows_left, rows_right)

        group_top =
          Enum.slice(map, idx - rows_to_compare, rows_to_compare)

        group_bottom =
          map
          |> Enum.slice(idx, rows_to_compare)
          |> Enum.reverse()

        {idx, group_top, group_bottom}
      end)

    case find_reflection_index(posible_reflection_groups, smudges) do
      {index, _, _} -> {index, :horizontal}
      _ -> nil
    end
  end

  defp find_reflection_index(possible_reflections, smudges)

  defp find_reflection_index(possible_reflections, true) do
    Enum.find(possible_reflections, fn {_idx, group_1, group_2} ->
      check_groups_smudges(group_1, group_2)
    end)
  end

  defp find_reflection_index(possible_reflections, false) do
    Enum.find(possible_reflections, fn {_idx, group_1, group_2} ->
      check_groups(group_1, group_2)
    end)
  end

  # Function to check if two groups of rows (around the mirrors) are equal.
  defp check_groups([], []), do: true
  defp check_groups([line | rest_1], [line | rest_2]), do: check_groups(rest_1, rest_2)
  defp check_groups(_, _), do: false

  # Function to check if two groups of rows (around the mirrors) has only one
  # difference. If they jave more or no differences it returns false.
  defp check_groups_smudges(group_1, group_2, already_fixed \\ false)

  # Only return true on finishing if a smudge has been fixed
  defp check_groups_smudges([], [], smudge), do: smudge

  defp check_groups_smudges([current_1 | rest_1], [current_2 | rest_2], already_fixed) do
    difference =
      for i <- 0..(length(current_1) - 1),
          Enum.at(current_1, i) != Enum.at(current_2, i) do
        Enum.at(current_1, i)
      end

    case {difference, already_fixed} do
      {[], _} -> check_groups_smudges(rest_1, rest_2, already_fixed)
      {[_something], false} -> check_groups_smudges(rest_1, rest_2, true)
      _ -> false
    end
  end
end
