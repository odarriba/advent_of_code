defmodule AdventOfCode.Year2023.Day3 do
  @moduledoc """
  Year 2023, Day 3

  https://adventofcode.com/2023/day/3
  """

  def run do
    AdventOfCode.input(2023, 3)
    |> AdventOfCode.Year2023.Day3.solve_part_1()
    |> IO.inspect(label: "Year 2023, Day 3, Part 1")

    AdventOfCode.input(2023, 3)
    |> AdventOfCode.Year2023.Day3.solve_part_2()
    |> IO.inspect(label: "Year 2023, Day 3, Part 2")
  end

  def solve_part_1(input) do
    data = parse_input(input)

    # Find numbers and coordenates
    possible_part_numbers = possible_part_numbers(data)
    possible_part_numbers = populate_coords_to_check(data, possible_part_numbers)

    possible_part_numbers
    |> Enum.filter(fn {_number, _coords, coords_to_check} ->
      Enum.any?(
        coords_to_check,
        fn {y, x} ->
          value = data |> Enum.at(y) |> Enum.at(x)
          not Regex.match?(~r/[0-9\.]/, value)
        end
      )
    end)
    |> Enum.reduce(0, fn {number, _, _}, acc -> number + acc end)
  end

  def solve_part_2(input) do
    data = parse_input(input)

    # Find numbers and coordenates
    possible_part_numbers = possible_part_numbers(data)
    possible_part_numbers = populate_coords_to_check(data, possible_part_numbers)

    {gear_coords, _} =
      Enum.reduce(data, {[], 0}, fn line, {acc, y} ->
        {acc, _, _} =
          Enum.reduce(line, {acc, y, 0}, fn
            "*", {acc, y, x} -> {[{y, x} | acc], y, x + 1}
            _, {acc, y, x} -> {acc, y, x + 1}
          end)

        {acc, y + 1}
      end)

    gear_coords
    |> Enum.map(fn coord ->
      possible_part_numbers
      |> Enum.filter(fn {_, _, coords_to_check} -> coord in coords_to_check end)
    end)
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.map(fn [{number_1, _, _}, {number_2, _, _}] -> number_1 * number_2 end)
    |> Enum.reduce(0, fn num, acc -> num + acc end)
  end

  defp parse_input(input) do
    Enum.map(input, &String.graphemes/1)
  end

  defp possible_part_numbers(data) do
    {possible_part_numbers, _} =
      Enum.reduce(data, {[], 0}, fn line, {acc, y} ->
        line_str = Enum.join(line)
        matches = Regex.scan(~r/(\D+|\d+)/, line_str)

        {acc, _, _} =
          Enum.reduce(matches, {acc, y, 0}, fn [match, _], {acc, y, x} ->
            case Integer.parse(match) do
              {number, ""} ->
                coords = for i <- 0..(String.length(match) - 1), do: {y, x + i}
                {[{number, coords} | acc], y, x + String.length(match)}

              :error ->
                {acc, y, x + String.length(match)}
            end
          end)

        {acc, y + 1}
      end)

    Enum.reverse(possible_part_numbers)
  end

  defp populate_coords_to_check(data, possible_part_numbers) do
    num_lines = length(data)

    Enum.map(possible_part_numbers, fn {number, coords} ->
      first_coord = List.first(coords)
      last_coord = List.last(coords)

      coords_to_check = [
        {elem(first_coord, 0), elem(first_coord, 1) - 1},
        {elem(first_coord, 0) - 1, elem(first_coord, 1) - 1},
        {elem(first_coord, 0) + 1, elem(first_coord, 1) - 1},
        {elem(last_coord, 0), elem(last_coord, 1) + 1},
        {elem(last_coord, 0) - 1, elem(last_coord, 1) + 1},
        {elem(last_coord, 0) + 1, elem(last_coord, 1) + 1}
      ]

      coords_to_check =
        Enum.reduce(coords, coords_to_check, fn coord, acc ->
          acc ++
            [
              {elem(coord, 0) + 1, elem(coord, 1)},
              {elem(coord, 0) - 1, elem(coord, 1)}
            ]
        end)

      coords_to_check =
        Enum.reject(coords_to_check, fn
          {y, x} when x < 0 or y < 0 ->
            true

          {y, x} ->
            line = Enum.at(data, y) || []
            y >= num_lines or x >= length(line)
        end)

      {number, coords, coords_to_check}
    end)
  end
end
