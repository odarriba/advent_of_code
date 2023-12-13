defmodule AdventOfCode.Year2023.Day6 do
  @moduledoc """
  Year 2023, Day 6

  https://adventofcode.com/2023/day/6
  """

  def solve(input, part) do
    input
    |> parse_input(part)
    |> Enum.map(fn {_race_id, %{time: time, distance: distance}} ->
      max_time_to_check =
        distance
        |> :math.sqrt()
        |> Float.ceil()

      minimum_time = get_minimum_time(0, max_time_to_check, time, distance)
      minimum_time = trunc(minimum_time)

      # Number of possibilities
      time - 2 * minimum_time + 1
    end)
    |> Enum.reject(&(&1 == 0))
    |> Enum.reduce(1, fn n, acc -> n * acc end)
  end

  defp parse_input(input, :first) do
    data =
      input
      |> Enum.map(fn line ->
        [type, data] = String.split(line, ":")

        type =
          case type do
            "Time" -> :time
            "Distance" -> :distance
          end

        numbers =
          data
          |> String.split(" ")
          |> Enum.reject(&(&1 == ""))
          |> Enum.map(&String.to_integer/1)

        {type, numbers}
      end)
      |> Enum.into(%{})

    times = data[:time]
    distances = data[:distance]

    0..(length(times) - 1)
    |> Enum.reduce(%{}, fn id, acc ->
      Map.put(acc, id, %{time: Enum.at(times, id), distance: Enum.at(distances, id)})
    end)
  end

  defp parse_input(input, :second) do
    data =
      input
      |> Enum.map(fn line ->
        [type, data] = String.split(line, ":")

        type =
          case type do
            "Time" -> :time
            "Distance" -> :distance
          end

        number =
          data
          |> String.replace(" ", "")
          |> String.to_integer()

        {type, [number]}
      end)
      |> Enum.into(%{})

    times = data[:time]
    distances = data[:distance]

    0..(length(times) - 1)
    |> Enum.reduce(%{}, fn id, acc ->
      Map.put(acc, id, %{time: Enum.at(times, id), distance: Enum.at(distances, id)})
    end)
  end

  defp get_minimum_time(checking_from, checking_to, total_time, distance) do
    if checking_from == checking_to - 1 do
      if checking_from * (total_time - checking_from) > distance,
        do: checking_from,
        else: checking_to
    else
      next_value = Float.floor((checking_to - checking_from) / 2.0) + checking_from

      if next_value * (total_time - next_value) > distance,
        do: get_minimum_time(checking_from, next_value, total_time, distance),
        else: get_minimum_time(next_value, checking_to, total_time, distance)
    end
  end
end

AdventOfCode.input(2023, 6)
|> AdventOfCode.Year2023.Day6.solve(:first)
|> IO.inspect(label: "Year 2023, Day 6, Part 1")

AdventOfCode.input(2023, 6)
|> AdventOfCode.Year2023.Day6.solve(:second)
|> IO.inspect(label: "Year 2023, Day 6, Part 2")
