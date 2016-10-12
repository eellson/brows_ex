defmodule BrowsEx.Renderer do
  @spec render(tuple, integer) :: tuple
  def render(tree, highlight \\ 1) do
    tree
    |> render_node(Integer.to_string(highlight))
    # |> IO.inspect
  end

  def render_node({"head", attributes, children}, highlight), do: nil
  def render_node({"a", attributes, children}, highlight) do
    attributes
    |> get_index
    |> render_link(highlight, children)
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

  def get_index(attributes) do
    {_, index} = attributes |> Enum.find(&({"brows_ex_index", index} = &1))

    index
  end

  def render_link(highlight, highlight, children) do
    ExNcurses.init_pair(1, ExNcurses.clr(:RED), ExNcurses.clr(:BLACK))
    ExNcurses.attron(1)
    render_link(children, highlight)
    ExNcurses.attroff(1)
  end
  def render_link(index, highlight, children), do: render_link(children, highlight)
  def render_link(children, highlight) do
    ExNcurses.printw("[")
    render_node(children, highlight)
    ExNcurses.printw("]")
  end
end
