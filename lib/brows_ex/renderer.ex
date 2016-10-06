
defmodule BrowsEx.Renderer do
  @spec render(tuple) :: tuple
  def render(tree) do
    # IO.inspect tree
    IO.puts render_node tree
  end

  @spec render_text_node(String.t) :: :ok
  def render_text_node(text), do: text

  def render_text_node('<title>', _text), do: ""
  def render_text_node('<h1>', text), do: text <> "\n" <> underline(text, "=")
  def render_text_node('<h2>', text), do: text <> "\n" <> underline(text, "-")
  def render_text_node('<p>', text), do: text <> "\n\n"
  def render_text_node('<em>', text), do: "_#{text}_"
  def render_text_node('<strong>', text), do: "*#{text}*"
  def render_text_node('<small>', text), do: text
  def render_text_node('<li>', text), do: "* #{text}" <> "\n\n"
  def render_text_node('<style type="text/css">', text), do: ""
  def render_text_node(name, text), do: text

  def render_node(text) when (is_binary(text) or is_list(text)) do
    render_text_node(text)
  end
  def render_node({name, [child]}) when is_binary child do
    render_text_node(name, child)
  end
  def render_node({name, [child]}) when is_tuple child do
    render_node(child)
  end
  def render_node({name, children}) when is_list children do
    render_node({name, [render_children(children)]})
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
