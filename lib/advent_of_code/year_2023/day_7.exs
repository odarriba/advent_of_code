defmodule AdventOfCode.Year2023.Day7 do
  @moduledoc """
  Year 2023, Day 7

  https://adventofcode.com/2023/day/7
  """

  @sorting_types [:high_card, :pair, :two_pairs, :three_kind, :full_house, :four_kind, :five_kind]
  @sorting_letters [
    first: ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"],
    second: ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]
  ]

  def solve(input, part) do
    grouped_hands =
      input
      |> parse_input(part)
      |> Enum.group_by(& &1[:type])

    sorted_hands =
      Enum.reduce(@sorting_types, [], fn type, acc ->
        group = Map.get(grouped_hands, type, [])

        sorted_hands =
          Enum.sort_by(group, & &1[:hand], fn h1, h2 ->
            Enum.reduce_while(1..5, nil, fn i, _acc ->
              letter_1 = Enum.at(h1, i - 1)
              letter_2 = Enum.at(h2, i - 1)
              weight_1 = Enum.find_index(@sorting_letters[part], &(&1 == letter_1))
              weight_2 = Enum.find_index(@sorting_letters[part], &(&1 == letter_2))

              cond do
                letter_1 == letter_2 -> {:cont, nil}
                weight_1 > weight_2 -> {:halt, false}
                true -> {:halt, true}
              end
            end)
          end)

        acc ++ sorted_hands
      end)

    1..length(sorted_hands)
    |> Enum.reduce(0, fn index, acc ->
      acc + index * Enum.at(sorted_hands, index - 1)[:bid]
    end)
  end

  defp parse_input(input, part) do
    input
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")

      hand = String.graphemes(hand)
      bid = String.to_integer(bid)

      type = get_type(hand, part)

      [hand: hand, bid: bid, type: type]
    end)
  end

  defp get_type(hand, part) do
    letters =
      Enum.reduce(hand, %{}, fn letter, acc ->
        letter_count = Map.get(acc, letter, 0) + 1
        Map.put(acc, letter, letter_count)
      end)

    {counts, jokers} = parse_letters(letters, part)

    cond do
      is_five_kind?(counts, jokers) -> :five_kind
      is_four_kind?(counts, jokers) -> :four_kind
      is_full_house?(counts, jokers) -> :full_house
      is_three_kind?(counts, jokers) -> :three_kind
      is_two_pairs?(counts, jokers) -> :two_pairs
      is_pair?(counts, jokers) -> :pair
      true -> :high_card
    end
  end

  defp parse_letters(letters, :first) do
    counts =
      letters
      |> Map.values()
      |> Enum.sort(:desc)

    {counts, 0}
  end

  defp parse_letters(letters, :second) do
    jokers = Map.get(letters, "J", 0)

    counts =
      letters
      |> Map.delete("J")
      |> Map.values()
      |> Enum.sort(:desc)

    {counts, jokers}
  end

  defp is_five_kind?([], 5), do: true
  defp is_five_kind?([_value], _jokers), do: true
  defp is_five_kind?(_other, _jokers), do: false

  defp is_four_kind?(_, 4), do: true
  defp is_four_kind?([h, _], jokers) when h + jokers == 4, do: true
  defp is_four_kind?(_counts, _jokers), do: false

  defp is_full_house?([3, 2], 0), do: true
  defp is_full_house?([3], 2), do: true
  defp is_full_house?([2], 3), do: true
  defp is_full_house?([a, 2], jokers) when a + jokers == 3, do: true
  defp is_full_house?([3, b], jokers) when b + jokers == 2, do: true
  defp is_full_house?(_, _), do: false

  defp is_three_kind?(_, 3), do: true
  defp is_three_kind?(counts, jokers), do: Enum.any?(counts, &(&1 + jokers == 3))

  defp is_two_pairs?([2, 1], 2), do: true
  defp is_two_pairs?([2, 2, 1], 0), do: true
  defp is_two_pairs?([2, 1, 1, 1], 1), do: true
  defp is_two_pairs?(_, _), do: false

  defp is_pair?(_, 2), do: true
  defp is_pair?(counts, jokers), do: Enum.any?(counts, &(&1 + jokers == 2))
end

AdventOfCode.input(2023, 7)
|> AdventOfCode.Year2023.Day7.solve(:first)
|> IO.inspect(label: "Year 2023, Day 7, Part 1")

AdventOfCode.input(2023, 7)
|> AdventOfCode.Year2023.Day7.solve(:second)
|> IO.inspect(label: "Year 2023, Day 7, Part 2")
