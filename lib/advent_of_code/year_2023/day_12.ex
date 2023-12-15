defmodule AdventOfCode.Year2023.Day12 do
  @moduledoc """
  Year 2023, Day 12

  https://adventofcode.com/2023/day/12
  """

  def run do
    # Cache agent
    Agent.start_link(fn -> %{} end, name: __MODULE__)

    AdventOfCode.input(2023, 12)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 12, Part 1")

    AdventOfCode.input(2023, 12)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 12, Part 2")
  end

  def solve(input, :first) do
    input
    |> parse_input()
    |> Enum.map(&calculate_combinations/1)
    |> Enum.sum()
  end

  def solve(input, :second) do
    input
    |> parse_input()
    |> unfold()
    |> Enum.map(&calculate_combinations/1)
    |> Enum.sum()
  end

  defp parse_input(input) do
    Enum.map(input, fn line ->
      [records, counters] = String.split(line, " ", trim: true)

      counters =
        counters
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      {records, counters}
    end)
  end

  def calculate_combinations({group, counters}), do: calculate_combinations(group, nil, counters)

  # Group string has reached the end successfully
  def calculate_combinations(<<>>, counter, []) when counter == 0 or is_nil(counter), do: 1

  # If there are counters missing or not matching the last one, it is a not
  # valid solution.
  def calculate_combinations(<<>>, _, _), do: 0

  # If we get to a broken spring and the counter is either nil (not in a group)
  # or zero (the last group finished successfully) we continue using `nil`as the
  # current counter.
  def calculate_combinations(<<".", rest::binary>>, counter, counters) when counter in [0, nil],
    do: calculate_combinations(rest, nil, counters)

  def calculate_combinations(<<".", _::binary>>, _, _), do: 0

  # We cannot process a group if there are not pending counters
  def calculate_combinations(<<"#", _::binary>>, nil, []), do: 0

  # We cannot process a group if the last one is already completed and there is
  # no `.`in the middle.
  def calculate_combinations(<<"#", _::binary>>, 0, _), do: 0

  # Start or continue in a group by decreasing the current counter.
  def calculate_combinations(<<"#", rest::binary>>, nil, [next_counter | other_counters]),
    do: calculate_combinations(rest, next_counter - 1, other_counters)

  def calculate_combinations(<<"#", rest::binary>>, counter, counters),
    do: calculate_combinations(rest, counter - 1, counters)

  # If we find an undetermination, we need to sum up possibilities of both
  # possible options (`.` and `#`).
  def calculate_combinations(<<"?", rest::binary>>, counter, counters) do
    cached_combinations("." <> rest, counter, counters) +
      cached_combinations("#" <> rest, counter, counters)
  end

  def cached_combinations(group, counter, counters) do
    cached_result =
      Agent.get(__MODULE__, fn state -> Map.get(state, {group, counter, counters}) end)

    if cached_result do
      cached_result
    else
      result = calculate_combinations(group, counter, counters)
      Agent.update(__MODULE__, fn state -> Map.put(state, {group, counter, counters}, result) end)

      result
    end
  end

  def unfold(data) do
    Enum.map(data, fn {group, counters} ->
      group = "#{group}?#{group}?#{group}?#{group}?#{group}"
      counters = counters ++ counters ++ counters ++ counters ++ counters

      {group, counters}
    end)
  end
end
