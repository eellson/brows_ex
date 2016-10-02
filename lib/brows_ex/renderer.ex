
defmodule BrowsEx.Renderer do
  @spec render(tuple) :: tuple
  def render(tree) do
    IO.inspect tree
    render_node tree
  end

  @spec render_text_node(String.t) :: :ok
  def render_text_node(text), do: IO.puts text

  def render_text_node(name, text), do: IO.puts text

  def render_node(text) when is_binary text do
    render_text_node(text)
  end
  def render_node({name, [child]}) when is_binary child do
    render_text_node(name, child)
  end
  def render_node({name, [child]}) when is_tuple child do
    render_node(child)
  end
  def render_node({name, children}) when is_list children do
    render_children(children)
  end

  def render_children([]), do: nil
  def render_children([child | tail]) do
    render_node(child)
    render_children(tail)
  end
end
