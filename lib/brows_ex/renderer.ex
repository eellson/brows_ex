
defmodule BrowsEx.Renderer do
  @spec render(tuple) :: tuple
  def render(tree) do
    # IO.inspect tree
    tree |> render_node

    # |> IO.puts 
  end

  @spec render_text_node(String.t) :: :ok
  def render_text_node(text), do: text

  def render_text_node("title", attributes, _text), do: ""
  def render_text_node("h1", attributes, text), do: text <> "\n" <> underline(text, "=")
  def render_text_node("h2", attributes, text), do: text <> "\n" <> underline(text, "-")
  def render_text_node("p", attributes, text), do: text <> "\n\n"
  def render_text_node("em", attributes, text), do: "_#{text}_"
  def render_text_node("strong", attributes, text), do: "*#{text}*"
  def render_text_node("small", attributes, text), do: text
  def render_text_node("ul", attributes, text), do: text <> "\n"
  def render_text_node("ol", attributes, text), do: text <> "\n"
  def render_text_node("li", attributes, text), do: "* #{text}" <> "\n"
  def render_text_node("script", attributes, text), do: ""
  def render_text_node("comment", text), do: ""
  def render_text_node("div", attributes, text), do: text <> "\n"
  def render_text_node("td", attributes, text), do: text <> "\n"
  def render_text_node(name, attributes, text) do
    # IO.puts "catch all, #{name}"
    text
  end

  def render_node(text) when (is_binary(text) or is_list(text)) do
    render_text_node(text)
  end
  def render_node({:comment, text}), do: render_text_node("comment", text)
  def render_node({name, attributes, [child]}) when is_binary child do
    render_text_node(name, attributes, child)
  end
  def render_node({name, attributes, [child]}) when is_tuple child do
    render_text_node(name, attributes, render_node(child))
  end
  def render_node({name, attributes, children}) when is_list children do
    render_node({name, attributes, [render_children(children)]})
  end

  def render_children([]), do: ""
  def render_children([child | tail]) do
    render_node(child) <> render_children(tail)
  end

  def underline(text, underline) do
    len = text |> String.length

    (List.duplicate(underline, len) |> List.to_string) <> "\n\n"
  end
end
