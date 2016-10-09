defmodule BrowsEx.Parser do
  @spec parse(binary) :: tuple
  def parse(input) do
    input
    |> Floki.parse
  end
end
