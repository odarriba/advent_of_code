defmodule AdventOfCode.Year2023.Day15 do
  @moduledoc """
  Year 2023, Day 15

  https://adventofcode.com/2023/day/15
  """

  def run do
    AdventOfCode.input(2023, 15)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 15, Part 1")

    AdventOfCode.input(2023, 15)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 15, Part 2")
  end

  def solve(input, :first) do
    data = parse_input(input)

    data
    |> Enum.map(&calculate_hash/1)
    |> Enum.sum()
  end

  def solve(input, :second) do
    data = parse_input(input)

    data
    |> initialization_process()
    |> calculate_power()
  end

  defp parse_input([input]) do
    String.split(input, ",", trim: true)
  end

  defp calculate_hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc -> rem((acc + char) * 17, 256) end)
  end

  defp initialization_process(commands, acc \\ %{})

  defp initialization_process([], acc), do: acc

  defp initialization_process([command | rest], acc) do
    [_, label, operation, focal] = Regex.run(~r/^([a-z]+)([\=\-])([0-9]?)/, command)

    box_id = calculate_hash(label)
    box = Map.get(acc, box_id, [])

    updated_box =
      case operation do
        "=" ->
          focal = String.to_integer(focal)

          if Enum.any?(box, &(elem(&1, 0) == label)) do
            Enum.reduce(box, [], fn
              {^label, _focal}, acc_box -> acc_box ++ [{label, focal}]
              element, acc_box -> acc_box ++ [element]
            end)
          else
            box ++ [{label, focal}]
          end

        "-" ->
          item = Enum.find(box, &(elem(&1, 0) == label))
          box -- [item]
      end

    upated_acc = Map.put(acc, box_id, updated_box)

    initialization_process(rest, upated_acc)
  end

  defp calculate_power(boxes) do
    for {box_id, box} <- boxes,
        box_elements = length(box),
        box_elements > 0,
        idx <- 0..(box_elements - 1),
        {_label, focal} = Enum.at(box, idx) do
      (box_id + 1) * (idx + 1) * focal
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end
end
