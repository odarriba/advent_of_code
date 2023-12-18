defmodule AdventOfCode.Year2023.Day17 do
  @moduledoc """
  Year 2023, Day 17

  https://adventofcode.com/2023/day/17
  """

  def run do
    AdventOfCode.input(2023, 17)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 17, Part 1")

    AdventOfCode.input(2023, 17)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 17, Part 2")
  end

  def solve(input, part) do
    {filtering_fn, min_steps} =
      case part do
        :first -> {&direction_filter_part_1/3, 1}
        :second -> {&direction_filter_part_2/3, 4}
      end

    map = parse_input(input)

    max_i =
      map
      |> Map.keys()
      |> Enum.map(&elem(&1, 0))
      |> Enum.max()

    max_j =
      map
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    heat_losses = %{
      {:right, 10, {0, 0}} => 0,
      {:down, 10, {0, 0}} => 0
    }

    heat_losses
    |> calc_heat_losses(map, Map.keys(heat_losses), filtering_fn)
    |> Enum.filter(fn {{_, steps, coord}, _} -> coord == {max_i, max_j} && steps >= min_steps end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.min()
  end

  defp parse_input(input) do
    input = Enum.map(input, &String.graphemes/1)

    max_i = length(input) - 1

    for i <- 0..max_i,
        line = Enum.at(input, i),
        j <- 0..(length(line) - 1),
        element = Enum.at(line, j),
        into: %{} do
      {{i, j}, String.to_integer(element)}
    end
  end

  defp calc_heat_losses(heat_losses, _map, [], _filtering_fn), do: heat_losses

  defp calc_heat_losses(heat_losses, map, to_check, filtering_fn) do
    {upd_heat_losses, upd_to_check} =
      Enum.reduce(to_check, {heat_losses, []}, &do_calc_heat_losses(&1, &2, map, filtering_fn))

    calc_heat_losses(upd_heat_losses, map, Enum.uniq(upd_to_check), filtering_fn)
  end

  defp direction_filter_part_1({d, _coord}, current_direction, steps) do
    case {d, current_direction, steps} do
      {d, d, s} when s >= 3 -> true
      {:up, :down, _} -> true
      {:down, :up, _} -> true
      {:right, :left, _} -> true
      {:left, :right, _} -> true
      _ -> false
    end
  end

  defp direction_filter_part_2({d, _coord}, current_direction, steps) do
    case {d, current_direction, steps} do
      {d, d, s} when s >= 10 -> true
      {d2, d1, s} when d1 != d2 and s < 4 -> true
      {:up, :down, _} -> true
      {:down, :up, _} -> true
      {:right, :left, _} -> true
      {:left, :right, _} -> true
      _ -> false
    end
  end

  defp do_calc_heat_losses(
         {current_direction, steps, {i, j}} = current_key,
         {acc_heat, acc_to_check},
         map,
         filtering_fn
       ) do
    [
      {:up, {i - 1, j}},
      {:down, {i + 1, j}},
      {:left, {i, j - 1}},
      {:right, {i, j + 1}}
    ]
    |> Enum.reject(&filtering_fn.(&1, current_direction, steps))
    |> Enum.filter(fn {_d, coord} -> Map.has_key?(map, coord) end)
    |> Enum.reduce({acc_heat, acc_to_check}, fn {direction, coord}, {acc_heat2, acc_to_check2} ->
      steps = if direction == current_direction, do: steps + 1, else: 1
      key = {direction, steps, coord}
      heat_loss = Map.fetch!(map, coord) + Map.fetch!(acc_heat2, current_key)

      if not Map.has_key?(acc_heat2, key) || Map.get(acc_heat2, key) > heat_loss do
        {
          Map.put(acc_heat2, key, heat_loss),
          acc_to_check2 ++ [key]
        }
      else
        {acc_heat2, acc_to_check2}
      end
    end)
  end
end
