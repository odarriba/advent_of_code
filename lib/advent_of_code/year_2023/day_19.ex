defmodule AdventOfCode.Year2023.Day19 do
  @moduledoc """
  Year 2023, Day 19

  https://adventofcode.com/2023/day/19
  """

  def run do
    AdventOfCode.raw_input(2023, 19)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 19, Part 1")

    AdventOfCode.raw_input(2023, 19)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 19, Part 2")
  end

  def solve(input, :first) do
    input
    |> parse_input()
    |> filter_accepted()
    |> sum_accepted()
  end

  def solve(input, :second) do
    input
    |> parse_input()
    |> find_accepted_ranges()
    |> List.flatten()
    |> Enum.map(fn possibilities ->
      possibilities
      |> Enum.map(fn {_v, r} -> length(r) end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    [instructions, pieces] = String.split(input, "\n\n", trim: true)

    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.reduce([], fn line, acc ->
        [_, name, filters] = Regex.run(~r/([a-z]+)\{([a-zA-Z0-9\>\<\=\:\,]+)\}/, line)

        filters =
          filters
          |> String.split(",", trim: true)
          |> Enum.map(fn command ->
            cond do
              # Just change step without evluating anything
              not String.contains?(command, ":") ->
                {nil, command}

              true ->
                variable = String.slice(command, 0, 1)
                operation = String.slice(command, 1, 1)
                rest = String.slice(command, 2..-1)
                [number, destination] = String.split(rest, ":", trim: true)
                number = String.to_integer(number)

                {{operation, variable, number}, destination}
            end
          end)

        acc ++ [{name, filters}]
      end)

    pieces =
      pieces
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.replace_prefix("{", "")
        |> String.replace_suffix("}", "")
        |> String.split(",")
        |> Enum.map(&String.split(&1, "="))
        |> Enum.map(fn [k, v] -> {k, String.to_integer(v)} end)
        |> Enum.into(%{})
      end)

    {pieces, instructions}
  end

  defp filter_accepted({pieces, instructions}) do
    Enum.reduce(pieces, [], fn piece, acc ->
      if piece_approved?(piece, instructions), do: [piece | acc], else: acc
    end)
  end

  defp piece_approved?(piece, instructions, phase \\ "in") do
    {_name, operations} = Enum.find(instructions, fn {name, _} -> name == phase end)

    {_, result} =
      Enum.find(operations, fn
        {nil, _} -> true
        {{">", variable, number}, _} -> Map.get(piece, variable) > number
        {{"<", variable, number}, _} -> Map.get(piece, variable) < number
      end)

    case result do
      "A" -> true
      "R" -> false
      other -> piece_approved?(piece, instructions, other)
    end
  end

  defp find_accepted_ranges({_pieces, instructions}) do
    initial_status = %{
      "x" => Enum.to_list(1..4000),
      "m" => Enum.to_list(1..4000),
      "a" => Enum.to_list(1..4000),
      "s" => Enum.to_list(1..4000)
    }

    do_find_accepted_ranges(instructions, initial_status, "in")
  end

  defp do_find_accepted_ranges(_instructions, status, "A"), do: status

  defp do_find_accepted_ranges(_instructions, _status, "R"), do: []

  defp do_find_accepted_ranges(instructions, status, step) do
    {_, step_instructions} = Enum.find(instructions, &(elem(&1, 0) == step))
    num_instructions = length(step_instructions)

    Enum.map(0..(num_instructions - 1), fn inst_idx ->
      past_instructions = Enum.slice(step_instructions, 0, inst_idx)
      {instruction, next} = Enum.at(step_instructions, inst_idx)

      status_rem =
        Enum.reduce(past_instructions, status, fn
          {{">", var, limit}, _}, acc ->
            Map.update!(acc, var, fn r -> Enum.reject(r, &(&1 > limit)) end)

          {{"<", var, limit}, _}, acc ->
            Map.update!(acc, var, fn r -> Enum.reject(r, &(&1 < limit)) end)
        end)

      status =
        case instruction do
          nil -> status_rem
          {">", v, lim} -> Map.update!(status_rem, v, fn r -> Enum.filter(r, &(&1 > lim)) end)
          {"<", v, lim} -> Map.update!(status_rem, v, fn r -> Enum.filter(r, &(&1 < lim)) end)
        end

      do_find_accepted_ranges(instructions, status, next)
    end)
  end

  defp sum_accepted(accepted) do
    Enum.reduce(accepted, 0, fn element, acc ->
      acc + Enum.sum(Map.values(element))
    end)
  end
end
