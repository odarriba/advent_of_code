defmodule AdventOfCode.Year2023.Day10 do
  @moduledoc """
  Year 2023, Day 10

  https://adventofcode.com/2023/day/10
  """

  def run do
    AdventOfCode.input(2023, 10)
    |> solve(:first)
    |> IO.inspect(label: "Year 2023, Day 10, Part 1")

    AdventOfCode.input(2023, 10)
    |> solve(:second)
    |> IO.inspect(label: "Year 2023, Day 10, Part 2")
  end

  def solve(input, :first) do
    data = parse_input(input)

    {start_i, start_j} = find_start_coords(data)
    path = calculate_path(data, [{start_i, start_j}])

    path
    |> length()
    |> div(2)
  end

  def solve(input, :second) do
    data = parse_input(input)

    {start_i, start_j} = find_start_coords(data)
    path = calculate_path(data, [{start_i, start_j}])
    path_max_index = length(path) - 1

    # Shoelace formula
    area =
      Enum.reduce(0..path_max_index, 0, fn i, acc ->
        {current_i, current_j} = Enum.at(path, i)

        if i == path_max_index do
          {first_i, first_j} = Enum.at(path, 0)
          acc + (current_i + first_i) * (current_j - first_j)
        else
          {next_i, next_j} = Enum.at(path, i + 1)
          acc + (current_i + next_i) * (current_j - next_j)
        end
      end)
      |> div(2)

    # Pick's theorem
    inner_area = area - length(path) / 2 + 1

    trunc(inner_area)
  end

  defp parse_input(input), do: Enum.map(input, &String.graphemes/1)

  defp find_start_coords(data) do
    [{i, j}] =
      for i <- 0..(length(data) - 1),
          line = Enum.at(data, i),
          j <- 0..(length(line) - 1),
          get_coord(data, {i, j}) == "S" do
        {i, j}
      end

    {i, j}
  end

  defp get_coord(data, {i, j}) do
    data
    |> Enum.at(i)
    |> Enum.at(j)
  end

  defp calculate_path(data, [{i, j} | _] = path) do
    possible_new_coords =
      data
      |> get_coord({i, j})
      |> coords_to_explore(i, j)

    # Remove already visited coords
    new_coords = Enum.reject(possible_new_coords, fn {i, j, _} -> {i, j} in path end)

    if new_coords == [] do
      path
    else
      {new_i, new_j, _} =
        Enum.find(new_coords, fn {i, j, direction} ->
          coord_value = get_coord(data, {i, j})

          case direction do
            :top -> coord_value in ["S", "|", "7", "F"]
            :bottom -> coord_value in ["S", "|", "J", "L"]
            :right -> coord_value in ["S", "-", "7", "J"]
            :left -> coord_value in ["S", "-", "F", "L"]
          end
        end)

      calculate_path(data, [{new_i, new_j} | path])
    end
  end

  defp coords_to_explore(value, i, j) do
    case value do
      "S" ->
        [
          {i - 1, j, :top},
          {i + 1, j, :bottom},
          {i, j - 1, :left},
          {i, j + 1, :right}
        ]

      "-" ->
        [
          {i, j - 1, :left},
          {i, j + 1, :right}
        ]

      "|" ->
        [
          {i - 1, j, :top},
          {i + 1, j, :bottom}
        ]

      "L" ->
        [
          {i - 1, j, :top},
          {i, j + 1, :right}
        ]

      "J" ->
        [
          {i - 1, j, :top},
          {i, j - 1, :left}
        ]

      "7" ->
        [
          {i + 1, j, :bottom},
          {i, j - 1, :left}
        ]

      "F" ->
        [
          {i + 1, j, :bottom},
          {i, j + 1, :right}
        ]
    end
  end
end
