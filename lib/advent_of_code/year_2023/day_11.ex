defmodule AdventOfCode.Year2023.Day11 do
  @moduledoc """
  Year 2023, Day 11

  https://adventofcode.com/2023/day/11
  """

  def run do
    AdventOfCode.input(2023, 11)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 11, Part 1")

    AdventOfCode.input(2023, 11)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 11, Part 2")
  end

  def solve(input, :first) do
    input
    |> parse_input()
    |> expand_universe(2)
    |> generate_pairs()
    |> Enum.map(fn [{i1, j1}, {i2, j2}] -> abs(i2 - i1) + abs(j2 - j1) end)
    |> Enum.sum()
  end

  def solve(input, :second) do
    input
    |> parse_input()
    |> expand_universe(1_000_000)
    |> generate_pairs()
    |> Enum.map(fn [{i1, j1}, {i2, j2}] -> abs(i2 - i1) + abs(j2 - j1) end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    # Returns a list of coordinates of galaxies.
    for i <- 0..(length(input) - 1),
        elements = input |> Enum.at(i) |> String.graphemes(),
        j <- 0..length(elements),
        Enum.at(elements, j) == "#" do
      {i, j}
    end
  end

  defp expand_universe(universe, base_factor) do
    {max_i, _} = Enum.max_by(universe, &elem(&1, 0))
    {_, max_j} = Enum.max_by(universe, &elem(&1, 1))

    # Expand by rows (vertically)

    {universe, _} =
      Enum.reduce(0..max_i, {[], 0}, fn i, {acc, expand_factor} ->
        galaxies = Enum.filter(universe, &(elem(&1, 0) == i))

        if galaxies == [] do
          {acc, expand_factor + base_factor - 1}
        else
          galaxies_updated = Enum.map(galaxies, fn {i, j} -> {i + expand_factor, j} end)
          {acc ++ galaxies_updated, expand_factor}
        end
      end)

    # Expand by columns (horizontally)
    {universe, _} =
      Enum.reduce(0..max_j, {[], 0}, fn j, {acc, expand_factor} ->
        galaxies = Enum.filter(universe, &(elem(&1, 1) == j))

        if galaxies == [] do
          {acc, expand_factor + base_factor - 1}
        else
          galaxies_updated = Enum.map(galaxies, fn {i, j} -> {i, j + expand_factor} end)
          {acc ++ galaxies_updated, expand_factor}
        end
      end)

    Enum.sort(universe)
  end

  defp generate_pairs(galaxies) do
    max_id = length(galaxies) - 1

    for id <- 0..max_id,
        id != max_id,
        id_pair <- (id + 1)..max_id do
      [Enum.at(galaxies, id), Enum.at(galaxies, id_pair)]
    end
  end
end
