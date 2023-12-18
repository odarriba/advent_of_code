defmodule AdventOfCode.Year2023.Day18 do
  @moduledoc """
  Year 2023, Day 18

  https://adventofcode.com/2023/day/18
  """

  def run do
    AdventOfCode.input(2023, 18)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 18, Part 1")

    AdventOfCode.input(2023, 18)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 18, Part 2")
  end

  def solve(input, part) do
    input
    |> parse_input(part)
    |> calculate_area()
  end

  defp parse_input(input, part) do
    {coords, length} =
      input
      |> Enum.map(fn line ->
        [movement, units, color] = String.split(line, " ")

        case part do
          :first ->
            {movement, String.to_integer(units), color}

          :second ->
            [_, units_hex, mov_hex] = Regex.run(~r/\(\#([a-zA-Z0-9]{5})([a-zA-Z0-9]{1})\)/, color)

            {units, ""} = Integer.parse(units_hex, 16)

            movement =
              case mov_hex do
                "0" -> "R"
                "1" -> "D"
                "2" -> "L"
                "3" -> "U"
              end

            {movement, units, color}
        end
      end)
      |> Enum.reduce({[{0, 0}], 0}, fn
        {"U", units, _}, {[{i, j} | _] = acc, counter} ->
          {[{i - units, j} | acc], counter + units}

        {"D", units, _}, {[{i, j} | _] = acc, counter} ->
          {[{i + units, j} | acc], counter + units}

        {"L", units, _}, {[{i, j} | _] = acc, counter} ->
          {[{i, j - units} | acc], counter + units}

        {"R", units, _}, {[{i, j} | _] = acc, counter} ->
          {[{i, j + units} | acc], counter + units}
      end)

    coords =
      coords
      |> Enum.reverse()
      |> Enum.uniq()

    {coords, length}
  end

  defp calculate_area({coords, length}) do
    last_idx = length(coords) - 1

    inside =
      0..last_idx
      |> Enum.reduce(0, fn idx, acc ->
        {i1, j1} = Enum.at(coords, idx)

        {i2, j2} =
          if idx == last_idx,
            do: Enum.at(coords, 0),
            else: Enum.at(coords, idx + 1)

        acc + (i1 + i2) * (j1 - j2)
      end)
      |> div(2)

    # We need to take into account the perimeter: a line of [{0,0}, {0, 1}] has
    # 2 square meters, but the Shoelace algoriythm will only give 0.5.
    # Afterwards I learnt this is calles Pick´s Theorem
    # https://en.wikipedia.org/wiki/Pick%27s_theorem
    trunc(inside + 1 + length / 2)
  end
end
