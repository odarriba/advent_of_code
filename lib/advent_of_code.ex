defmodule AdventOfCode do
  @moduledoc """
  `AdventOfCode` main module, containing mostly helpers.
  """

  def input(year, day, file \\ "input.txt") do
    raw_input(year, day, file)
    |> String.split("\n", trim: true)
  end

  def raw_input(year, day, file \\ "input.txt") do
    base_dir = :code.priv_dir(:advent_of_code)

    [base_dir, "inputs", "year_#{year}", "day_#{day}", file]
    |> Path.join()
    |> File.read!()
  end
end
