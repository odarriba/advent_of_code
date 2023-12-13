defmodule AdventOfCode.Year2023.Day4 do
  @moduledoc """
  Year 2023, Day 4

  https://adventofcode.com/2023/day/4
  """

  def solve_part_1(input) do
    input
    |> parse_input()
    |> Enum.reduce(0, fn {_, %{matches: matches}}, acc ->
      case length(matches) do
        0 -> acc
        num -> acc + :math.pow(2, num - 1)
      end
    end)
    |> trunc()
  end

  def solve_part_2(input) do
    data = parse_input(input)

    card_ids = data |> Map.keys() |> Enum.sort()

    card_ids
    |> Enum.reduce(data, fn card_id, acc ->
      card = acc[card_id]
      num_matches = length(card[:matches])

      if num_matches > 0 do
        card_ids_to_upgrade = for i <- 1..num_matches, do: card_id + i
        card_ids_to_upgrade = Enum.filter(card_ids_to_upgrade, &(&1 in card_ids))

        Enum.reduce(card_ids_to_upgrade, acc, fn cid, acc_upgraded ->
          Map.update!(acc_upgraded, cid, fn card_to_upgrade ->
            %{card_to_upgrade | instances: card_to_upgrade[:instances] + card[:instances]}
          end)
        end)
      else
        acc
      end
    end)
    |> Enum.reduce(0, fn {_, %{instances: num_cards}}, acc -> acc + num_cards end)
  end

  defp parse_input(input) do
    input
    |> Enum.map(fn card ->
      [card_id, contents] = String.split(card, ":")

      [winning_numbers, card_numbers] =
        contents
        |> String.trim()
        |> String.split(" | ")

      card_number =
        card_id
        |> String.trim_leading("Card")
        |> String.trim()
        |> String.to_integer()

      winning_numbers = parse_numbers(winning_numbers)
      card_numbers = parse_numbers(card_numbers)
      matches = Enum.filter(winning_numbers, &(&1 in card_numbers))

      {card_number,
       %{
         instances: 1,
         winning_numbers: winning_numbers,
         card_numbers: card_numbers,
         matches: matches
       }}
    end)
    |> Enum.into(%{})
  end

  defp parse_numbers(str) do
    str
    |> String.trim()
    |> String.split(" ")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end
end

AdventOfCode.input(2023, 4)
|> AdventOfCode.Year2023.Day4.solve_part_1()
|> IO.inspect(label: "Year 2023, Day 4, Part 1")

AdventOfCode.input(2023, 4)
|> AdventOfCode.Year2023.Day4.solve_part_2()
|> IO.inspect(label: "Year 2023, Day 4, Part 2")
