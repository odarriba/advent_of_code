defmodule AdventOfCode.Year2023.Day20 do
  @moduledoc """
  Year 2023, Day 20

  https://adventofcode.com/2023/day/20
  """

  def run do
    AdventOfCode.input(2023, 20)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 20, Part 1")

    AdventOfCode.input(2023, 20)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 20, Part 2")
  end

  def solve(input, :first) do
    parsed_input = parse_input(input)
    initial_state = generate_state(parsed_input)

    {num_highs, num_lows, _} =
      Enum.reduce(1..1000, {0, 0, initial_state}, fn _, {acc_high, acc_low, acc_state} ->
        {num_highs, num_lows, new_state, _events} = pulse_button(parsed_input, acc_state)
        {acc_high + num_highs, acc_low + num_lows, new_state}
      end)

    num_highs * num_lows
  end

  def solve(input, :second) do
    parsed_input = parse_input(input)
    initial_state = generate_state(parsed_input)

    [{_source_of_rx, %{type: :conjunction, inputs: source_inputs}}] =
      Enum.filter(parsed_input, fn {_, %{outputs: outputs}} -> "rx" in outputs end)

    parsed_input
    |> find_presses(initial_state, dbg(source_inputs))
    |> Enum.reduce(&lowest_common_denominator/2)
  end

  defp parse_input(input) do
    modules =
      Enum.reduce(input, [], fn line, acc ->
        [element, outputs] = String.split(line, " -> ", trim: true)

        outputs = String.split(outputs, ", ", trim: true)

        module =
          case element do
            <<?&, name::binary>> -> {:conjunction, name, outputs}
            <<?%, name::binary>> -> {:flip_flop, name, outputs}
            name -> {:broadcaster, name, outputs}
          end

        acc ++ [module]
      end)

    modules
    |> Enum.map(fn {type, name, outputs} ->
      inputs =
        modules
        |> Enum.filter(fn {_, _, outputs} -> name in outputs end)
        |> Enum.map(&elem(&1, 1))

      {name, %{type: type, inputs: inputs, outputs: outputs}}
    end)
    |> Enum.into(%{})
  end

  defp pulse_button(input, state) do
    broadcaster = Map.fetch!(input, "broadcaster")

    initial_low = 1 + length(broadcaster.outputs)

    initial_changes =
      broadcaster
      |> Map.fetch!(:outputs)
      |> Enum.map(&{&1, :low, "broadcaster"})

    process_changes(input, state, initial_changes, {0, initial_low}, [])
  end

  defp process_changes(_input, state, [], {acc_hi, acc_lo}, events),
    do: {acc_hi, acc_lo, state, events}

  defp process_changes(
         input,
         state,
         [{name, pulse, sender} | other_changes],
         acc_pulses,
         acc_events
       ) do
    {acc_hi, acc_lo} = acc_pulses

    {new_pending, state, acc_hi, acc_lo} =
      if element = Map.get(input, name) do
        current_element_state = Map.fetch!(state, name)
        new_state = process_element_state(element, name, pulse, state)

        state = Map.put(state, name, new_state)

        if new_state == current_element_state and element.type != :conjunction do
          {[], state, acc_hi, acc_lo}
        else
          num_outputs = length(element.outputs)

          {acc_hi, acc_lo} =
            if new_state == :low,
              do: {acc_hi, acc_lo + num_outputs},
              else: {acc_hi + num_outputs, acc_lo}

          new_pending = Enum.map(element.outputs, &{&1, new_state, name})
          {new_pending, state, acc_hi, acc_lo}
        end
      else
        {[], state, acc_hi, acc_lo}
      end

    new_events = [{name, pulse, sender} | acc_events]
    process_changes(input, state, other_changes ++ new_pending, {acc_hi, acc_lo}, new_events)
  end

  defp find_presses(input, state, to_find, presses \\ 1, found \\ []) do
    {_acc_hi, _acc_lo, new_state, events} = pulse_button(input, state)

    found_events =
      Enum.filter(to_find, fn name ->
        events
        |> Enum.filter(fn {_, _, sender} -> sender == name end)
        |> List.last()
        |> elem(1)
        |> Kernel.==(:high)
      end)

    missing_to_find = to_find -- found_events
    found = if found_events == [], do: found, else: [presses | found]

    if missing_to_find == [],
      do: found,
      else: find_presses(input, new_state, missing_to_find, presses + 1, found)
  end

  defp process_element_state(%{type: :flip_flop}, name, :low, state) do
    status = Map.fetch!(state, name)
    if status == :low, do: :high, else: :low
  end

  defp process_element_state(%{type: :flip_flop}, name, :high, state),
    do: Map.fetch!(state, name)

  defp process_element_state(%{type: :conjunction, inputs: inputs}, _name, _, state) do
    all_high =
      inputs
      |> Enum.map(&Map.fetch!(state, &1))
      |> Enum.all?(&(&1 == :high))

    if all_high, do: :low, else: :high
  end

  defp process_element_state(%{type: :none}, name, _, state),
    do: Map.fetch!(state, name)

  defp generate_state(input) do
    Enum.reduce(input, %{}, fn
      {name, %{type: :broadcaster}}, acc -> Map.put(acc, name, :low)
      {name, %{type: :flip_flop}}, acc -> Map.put(acc, name, :low)
      {name, %{type: :none}}, acc -> Map.put(acc, name, :low)
      {name, %{type: :conjunction}}, acc -> Map.put(acc, name, :high)
    end)
  end

  def lowest_common_denominator(a, b), do: div(a * b, Integer.gcd(a, b))
end
