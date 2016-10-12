defmodule BrowsEx.Renderer do
  @spec render(tuple, integer) :: tuple
  def render(tree, highlight) do
    tree
    |> render_node(Integer.to_string(highlight))
  end

  @spec render_text_node(String.t, integer) :: :ok
  def render_text_node(text, highlight), do: text

  def render_text_node("title", attributes, _text, highlight), do: ""
  def render_text_node("h1", attributes, text, highlight), do: text <> "\n" <> underline(text, "=")
  def render_text_node("h2", attributes, text, highlight), do: text <> "\n" <> underline(text, "-")
  def render_text_node("p", attributes, text, highlight), do: text <> "\n\n"
  def render_text_node("em", attributes, text, highlight), do: "_#{text}_"
  def render_text_node("strong", attributes, text, highlight), do: "*#{text}*"
  def render_text_node("small", attributes, text, highlight), do: text
  def render_text_node("ul", attributes, text, highlight), do: text <> "\n"
  def render_text_node("ol", attributes, text, highlight), do: text <> "\n"
  def render_text_node("li", attributes, text, highlight), do: "* #{text}" <> "\n"
  def render_text_node("script", attributes, text, highlight), do: ""
  def render_text_node("comment", text, highlight), do: ""
  def render_text_node("div", attributes, text, highlight), do: text <> "\n"
  def render_text_node("td", attributes, text, highlight), do: text <> "\n"
  def render_text_node("a", attributes, text, highlight) do
    handle_link(text, get_index(attributes), highlight)
  end
  def render_text_node(name, attributes, text, highlight) do
    # IO.puts "catch all, #{name}"
    text
  end

  def get_index(list) do
    {_, index} = list |> Enum.find(&({"brows_ex_index", index} = &1))

    index
    # |> IO.inspect
  end

  def handle_link(text, index, highlight) when index == highlight do
    "[#{text |> String.upcase}]"
  end
  def handle_link(text, index, highlight) do
    "[#{text}]"
  end

  def render_node(text, highlight) when (is_binary(text) or is_list(text)) do
    render_text_node(text, highlight)
  end
  def render_node({:comment, text}, highlight), do: render_text_node("comment", text, highlight)
  def render_node({name, attributes, [child]}, highlight) when is_binary child do
    render_text_node(name, attributes, child, highlight)
  end
  def render_node({name, attributes, [child]}, highlight) when is_tuple child do
    render_text_node(name, attributes, render_node(child, highlight), highlight)
  end
  def render_node({name, attributes, children}, highlight) when is_list children do
    render_node({name, attributes, [render_children(children, highlight)]}, highlight)
  end

  def render_children([], highlight), do: ""
  def render_children([child | tail], highlight) do
    render_node(child, highlight) <> render_children(tail, highlight)
  end

  def underline(text, underline) do
    len = text |> String.length

    (List.duplicate(underline, len) |> List.to_string) <> "\n\n"
  end
end
