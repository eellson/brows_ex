defmodule BrowsEx.Renderer do
  alias BrowsEx.Line

  def init do
    :application.start(:cecho)
    :cecho.start_color
    :cecho.init_pair(1, 1, 0) # red
    :cecho.init_pair(2, 2, 0) # green
    :cecho.init_pair(3, 3, 0) # yellow
    :cecho.init_pair(4, 4, 0) # blue
    :cecho.init_pair(5, 5, 0) # purple
    :cecho.init_pair(6, 6, 0) # cyan
    :cecho.init_pair(7, 7, 0) # white
    :cecho.init_pair(8, 8, 0) # grey
    :cecho.cbreak
  end

  def term do
    :application.stop(:cecho)
    System.halt
  end

  def render(_url, tree, page \\ 0) do
    :cecho.erase

    # print_title("BrowsEx = #{url}")

    tree |> paginate |> render_lines(page)

    :cecho.refresh
  end

  defp paginate(tree), do: BrowsEx.Paginator.paginate(tree)

  defp render_lines(pages, current) do
    pages |> Enum.at(current) |> Enum.map(&execute_line/1)
  end

  defp execute_line(%Line{instructions: instructions}) do
    instructions |> Enum.map(fn {func, arg} -> func.(arg) end)
    :cecho.addch(?\n)
  end
end
