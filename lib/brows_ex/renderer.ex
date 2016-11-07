defmodule BrowsEx.Renderer do
  use Bitwise

  @no_render ~w(head script)

  @spec render(tuple, integer) :: tuple
  def render(tree, highlight \\ 1) do
    tree
    |> render_node(Integer.to_string(highlight))
  end

  def render_node({"a", attributes, children}, highlight) do
    attributes
    |> get_index
    |> render_link(highlight, children)
  end
  def render_node({name, attributes, children}, highlight) when name in @no_render, do: nil
  def render_node({name, attributes, children}, highlight) do
    render_node(children, highlight)
  end
  def render_node([head|tail], highlight) do
    [render_node(head, highlight), render_node(tail, highlight)]
  end
  def render_node(<<leaf::binary>>, highlight), do: leaf |> print
  def render_node(_other, highlight), do: nil

  def get_index(attributes) do
    {_, index} = attributes |> Enum.find(&({"brows_ex_index", index} = &1))

    index
  end

  def render_link(highlight, highlight, children) do
    :cecho.attron(5 <<< 8)
    render_link(children, highlight, "!", "!")
    :cecho.attroff(5 <<< 8)
  end
  def render_link(index, highlight, children) do
    :cecho.attron(4 <<< 8)
    render_link(children, highlight, "[", "]")
    :cecho.attroff(4 <<< 8)
  end
  def render_link(children, highlight, open, close) do
    print(open)
    render_node(children, highlight)
    print(close)
  end

  def print(string) do
    string
    |> String.to_char_list
    |> Enum.each(fn ch ->
      :cecho.addch(ch)
    end)
  end
end
