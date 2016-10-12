defmodule BrowsEx.Parser do
  @spec parse(binary) :: tuple
  def parse(html) do
    html |> Floki.parse
  end
end
