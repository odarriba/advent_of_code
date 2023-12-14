defmodule AdventOfCode.Year2023.Day5 do
  @moduledoc """
  Year 2023, Day 5

  https://adventofcode.com/2023/day/5
  """

  @conversion_maps [
    :seed_to_soil,
    :soil_to_fertilizer,
    :fertilizer_to_water,
    :water_to_light,
    :light_to_temperature,
    :temperature_to_humidity,
    :humidity_to_location
  ]

  def run do
    AdventOfCode.raw_input(2023, 5)
    |> AdventOfCode.Year2023.Day5.solve_part_1()
    |> IO.inspect(label: "Year 2023, Day 5, Part 1")

    AdventOfCode.raw_input(2023, 5)
    |> AdventOfCode.Year2023.Day5.solve_part_2()
    |> IO.inspect(label: "Year 2023, Day 5, Part 2")
  end

  def solve_part_1(input) do
    data = parse_input(input)

    data.seeds
    |> Enum.map(fn seed ->
      Enum.reduce(@conversion_maps, seed, fn map, acc -> convert_with_map(acc, data[map]) end)
    end)
    |> Enum.min()
  end

  def solve_part_2(input) do
    data = parse_input(input)

    intervals =
      data.seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [from, len] -> {from, from + len - 1} end)

    Enum.reduce(@conversion_maps, intervals, fn map_id, acc ->
      map = data[map_id]

      acc
      |> Enum.reduce([], fn {from, to}, acc_map ->
        # We need to calculate ranges using isntructions but taking into account
        # the part of the range already processed by previous instructions.
        {_, new_ranges} =
          Enum.reduce(map, {{from, to}, []}, fn inst, {{from, to}, acc} ->
            %{source_to: source_to, source_from: source_from, diff: diff} = inst

            cond do
              source_from <= from && source_to >= to ->
                {
                  {from, to},
                  acc ++ [{from + diff, to + diff}]
                }

              from < source_from && to > source_to ->
                {
                  {source_to + 1, to},
                  acc ++
                    [
                      {from, source_from - 1},
                      {source_from + diff, source_to + diff}
                    ]
                }

              from < source_from && source_from <= to ->
                {
                  {from, to},
                  acc ++ [{from, source_from - 1}, {source_from + diff, to + diff}]
                }

              source_to < to && source_to >= from ->
                {{source_to + 1, to}, acc ++ [{from + diff, source_to + diff}]}

              true ->
                {{from, to}, acc}
            end
          end)

        new_ranges = List.flatten(new_ranges)
        new_ranges = if new_ranges == [], do: [{from, to}], else: new_ranges
        acc_map ++ new_ranges
      end)
      |> Enum.uniq()
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  defp parse_input(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn
      # Seeds specification
      <<"seeds: ", rest::binary>> ->
        seeds =
          rest
          |> String.trim()
          |> String.split(" ")
          |> Enum.map(&String.to_integer/1)

        {:seeds, seeds}

      # Maps parsing
      str ->
        [map_type_str | lines] = String.split(str, "\n")

        map_type =
          case map_type_str do
            <<"seed-to-soil", _rest::binary>> -> :seed_to_soil
            <<"soil-to-fertilizer", _rest::binary>> -> :soil_to_fertilizer
            <<"fertilizer-to-water", _rest::binary>> -> :fertilizer_to_water
            <<"water-to-light", _rest::binary>> -> :water_to_light
            <<"light-to-temperature", _rest::binary>> -> :light_to_temperature
            <<"temperature-to-humidity", _rest::binary>> -> :temperature_to_humidity
            <<"humidity-to-location", _rest::binary>> -> :humidity_to_location
          end

        conversions =
          lines
          |> Enum.reject(&(&1 == ""))
          |> Enum.map(fn line ->
            [dest_from, source_from, interval] =
              line
              |> String.split(" ")
              |> Enum.map(&String.to_integer/1)

            %{
              source_from: source_from,
              source_to: source_from + interval - 1,
              diff: dest_from - source_from
            }
          end)
          |> Enum.sort_by(& &1.source_from, :asc)

        {map_type, conversions}
    end)
    |> Enum.into(%{})
  end

  defp convert_with_map(value, map) do
    instruction =
      Enum.find(map, fn inst ->
        inst.source_from <= value && value < inst.source_to
      end)

    if instruction, do: value + instruction.diff, else: value
  end
end
