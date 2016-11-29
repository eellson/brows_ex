defmodule BrowsEx.Renderer do
  alias BrowsEx.{Line, Page}
  use Bitwise

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

  def render(_url, page, cursor) do
    # IO.inspect cursor
    :cecho.erase

    # print_title("BrowsEx = #{url}")

    render_lines(page, cursor)
    # |> IO.inspect

    :cecho.refresh
  end

  def max, do: :cecho.getmaxyx
  def max(:x) do
    {_, x} = max
    x
  end
  def max(:y) do
    {y, _} = max
    y
  end

  defp render_lines(%Page{lines: lines}, cursor) do
    Enum.map(lines, &execute_line(&1, cursor))
  end

  defp execute_line(%Line{instructions: instructions}, cursor) do
    instructions |> Enum.each(&execute(&1, cursor))
    :cecho.addch(?\n)
  end

  defp execute({:start_h1}, _cursor), do: :cecho.attron(1 <<< 8)

  defp execute({:end_h1}, _cursor), do: :cecho.attroff(1 <<< 8)

  defp execute({:start_link, id, _target}, {_page, link}) when id == link do
    :cecho.attron(5 <<< 8)
  end
  defp execute({:start_link, _id, _target}, _cursor), do: :cecho.attron(3 <<< 8)

  defp execute({:end_link, id}, {_page, link}) when id == link, do: :cecho.attroff(5 <<< 8)
  defp execute({:end_link, _id}, _cursor), do: :cecho.attroff(3 <<< 8)

  defp execute({:print, string}, _cursor), do: print(string)

  defp print(str), do: str |> String.to_char_list |> Enum.each(fn ch -> :cecho.addch(ch) end)
end
