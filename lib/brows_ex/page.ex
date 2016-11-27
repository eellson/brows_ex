defmodule BrowsEx.Page do
  alias BrowsEx.{Line, Page}

  defstruct [height: 0, max: 0, lines: [], index: 0, link_count: 0]

  def index_links(%Page{lines: lines}=page) do
    {lines, count} = Enum.map_reduce(lines, 0, fn(%Line{instructions: instructions}=line, count) ->
      {instructions, count} = Enum.map_reduce(instructions, count, fn
        {:start_link, :id, url}, count -> {{:start_link, count, url}, count}
        {:end_link}, count -> {{:end_link, count}, count + 1}
        any, count -> {any, count}
      end)
      {%{line|instructions: instructions}, count}
    end)

    %{page|link_count: count, lines: lines}
  end
end
