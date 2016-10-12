defmodule BrowsEx.Renderer do
  @spec render(tuple, integer) :: tuple
  def render(tree, highlight \\ 1) do
    tree
    |> render_node(Integer.to_string(highlight))
    # |> IO.inspect
  end

  def render_node({"head", attributes, children}, highlight), do: nil
  def render_node({"a", attributes, children}, highlight) do
    ExNcurses.printw("[")
    render_node(children, highlight)
    ExNcurses.printw("]")
  end
  def render_node({name, attributes, children}, highlight) do
    render_node(children, highlight)
  end
  def render_node([head|tail], highlight) do
    [render_node(head, highlight), render_node(tail, highlight)]
  end
  def render_node(<<leaf::binary>>, highlight) do
    leaf
    |> ExNcurses.printw
    # |> IO.puts
  end
  def render_node(other, highlight), do: other
end
