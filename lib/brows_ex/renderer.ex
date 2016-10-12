defmodule BrowsEx.Renderer do
  @spec render(tuple, integer) :: tuple
  def render(tree, highlight \\ 1) do
    tree
    |> render_node(Integer.to_string(highlight))
    # |> IO.inspect
  end

  def render_node(<<leaf::binary>>, highlight) do
    leaf
    # |> IO.inspect
    |> ExNcurses.printw
    # |> IO.puts
  end
  def render_node({"head", attributes, children}, highlight), do: nil
  # def render_node({"html", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"body", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"h1", attributes, children}, highlight), do: render_node(children, highlight)
  def render_node({"a", attributes, children}, highlight) do
    ExNcurses.printw("[")
    render_node(children, highlight)
    ExNcurses.printw("]")
  end
  # def render_node({"p", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"em", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"div", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"ul", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"li", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"strong", attributes, children}, highlight), do: render_node(children, highlight)
  # def render_node({"small", attributes, children}, highlight), do: render_node(children, highlight)
  def render_node({name, attributes, children}, highlight) do
    # {name, attributes, render_node(children, highlight)}
    render_node(children, highlight)
    # handle_element({name, attributes, render_node(children, highlight)}, highlight)
  end
  def render_node([head|tail], highlight) do
    [render_node(head, highlight), render_node(tail, highlight)]
  end
  def render_node(other, highlight) do
    other
  end

  def handle_element({"html", _, contents}, _), do: contents
  def handle_element({"head", _, contents}, _), do: nil
  def handle_element({"title", _, contents}, _), do: nil
  def handle_element({"body", _, contents}, _), do: contents
  def handle_element({"div", _, contents}, _), do: contents
  def handle_element({"h1", _, contents}, _), do: contents
  def handle_element({"h2", _, contents}, _), do: contents
  def handle_element({"p", _, contents}, _), do: contents
  def handle_element({"em", _, contents}, _), do: contents
  def handle_element({"strong", _, contents}, _), do: contents
  def handle_element({"a", _, contents}, _), do: contents |> Enum.map(&ExNcurses.printw(&1))
  def handle_element({"small", _, contents}, _), do: contents
  def handle_element({"ul", _, contents}, _), do: contents
  def handle_element({"li", _, contents}, _), do: contents

  # def handle_element({"a", attributes, children}, highlight) do
  #   # IO.puts "BEFORE a"
  #   children
  #   # IO.puts "AFTER A"
  # end
  # def handle_element({name,_,text}, _) do
  #   # IO.puts "BEFORE elem #{name}"
  #   text
  #   # IO.puts "AFTER elem #{name}"
  # end

  # @spec render_text_node(String.t, integer) :: :ok
  # def render_text_node(text, highlight), do: text

  # def render_text_node("title", attributes, _text, highlight), do: ""
  # def render_text_node("h1", attributes, text, highlight), do: text <> "\n" <> underline(text, "=")
  # def render_text_node("h2", attributes, text, highlight), do: text <> "\n" <> underline(text, "-")
  # def render_text_node("p", attributes, text, highlight), do: text <> "\n\n"
  # def render_text_node("em", attributes, text, highlight), do: "_#{text}_"
  # def render_text_node("strong", attributes, text, highlight), do: "*#{text}*"
  # def render_text_node("small", attributes, text, highlight), do: text
  # def render_text_node("ul", attributes, text, highlight), do: text <> "\n"
  # def render_text_node("ol", attributes, text, highlight), do: text <> "\n"
  # def render_text_node("li", attributes, text, highlight), do: "* #{text}" <> "\n"
  # def render_text_node("script", attributes, text, highlight), do: ""
  # def render_text_node("comment", text, highlight), do: ""
  # def render_text_node("div", attributes, text, highlight), do: text <> "\n"
  # def render_text_node("td", attributes, text, highlight), do: text <> "\n"
  # def render_text_node("a", attributes, text, highlight) do
  #   handle_link(text, get_index(attributes), highlight)
  # end
  # def render_text_node(name, attributes, text, highlight) do
  #   # IO.puts "catch all, #{name}"
  #   text
  # end

  # def get_index(list) do
  #   {_, index} = list |> Enum.find(&({"brows_ex_index", index} = &1))

  #   index
  #   # |> IO.inspect
  # end

  # def handle_link(text, index, highlight) when index == highlight do
  #   "[#{text |> String.upcase}]"
  # end
  # def handle_link(text, index, highlight) do
  #   "[#{text}]"
  # end

  # def render_node(text, highlight) when (is_binary(text) or is_list(text)) do
  #   render_text_node(text, highlight)
  # end
  # def render_node({:comment, text}, highlight), do: render_text_node("comment", text, highlight)
  # def render_node({name, attributes, [child]}, highlight) when is_binary child do
  #   render_text_node(name, attributes, child, highlight)
  # end
  # def render_node({name, attributes, [child]}, highlight) when is_tuple child do
  #   render_text_node(name, attributes, render_node(child, highlight), highlight)
  # end
  # def render_node({name, attributes, children}, highlight) when is_list children do
  #   render_node({name, attributes, [render_children(children, highlight)]}, highlight)
  # end

  # def render_children([], highlight), do: ""
  # def render_children([child | tail], highlight) do
  #   render_node(child, highlight) <> render_children(tail, highlight)
  # end

  # def underline(text, underline) do
  #   len = text |> String.length

  #   (List.duplicate(underline, len) |> List.to_string) <> "\n\n"
  # end
end
