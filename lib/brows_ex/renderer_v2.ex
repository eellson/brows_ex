defmodule Line do
  defstruct [width: 0, max: 0, instructions: []]
end

defmodule BrowsEx.RendererV2 do
  use Bitwise

  @no_render ~w(head script)
  @block_level ~w(address article aside blockquote canvas dd div dl fieldset
    figcaption figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr li main nav
    noscript ol output p pre section table tfoot ul video tr)

  def render(tree) do
    {_height, width} = :cecho.getmaxyx
    {line, lines} = tree |> render_node(%Line{max: width}, [])

    [line|lines]
  end

  def render_node({"h1", _attrs, children}, %Line{}=line, lines) do
    {new_line, lines} =
      children
      |> render_node(%Line{instructions: [{&attr_on/1, 1}], max: line.max}, [line|lines])

    {%{new_line|instructions: [{&attr_off/1, 1}|new_line.instructions]}, lines}
  end
  def render_node({"a", attrs, children}, %Line{instructions: instructions}=line, lines) do
    {line, lines} = 
      children
      |> render_node(%{line|instructions: [{&attr_on/1, 5}|instructions]}, lines)

    {%{line|instructions: [{&attr_off/1, 5}|line.instructions]}, lines}
  end
  def render_node({"li", _attrs, children}, line, lines) do
    ["* "|children] |> render_node(%Line{max: line.max}, [line|lines])
  end
  def render_node({name, _attrs, children}, line, lines) when name in @no_render, do: {line, lines}
  def render_node({name, _attrs, children}, line, lines) when name in @block_level do
    render_node(children, %Line{max: line.max}, [line|lines])
  end
  def render_node({name, _attrs, children}, line, lines) do
    render_node(children, line, lines)
  end
  def render_node([child|siblings], line, lines) do
    {line, lines} = render_node(child, line, lines)
    render_node(siblings, line, lines)
  end
  def render_node([], line, lines), do: {line, lines}
  def render_node(<<leaf::binary>>, line, lines) do
    leaf |> String.split |> render_words(line, lines)
  end
  def render_node(_other, line, lines), do: {line, lines}

  def render_words([word|tail], %Line{max: max, width: width, instructions: instructions}=line, lines) do
    case String.length(word) + width do
      new_width when new_width >= max ->
        render_words([word|tail], %Line{max: max}, [line|lines])
      new_width ->
        render_words(tail, %{line|width: new_width + 1, instructions: [{&print/1, "#{word} "}|instructions]}, lines)
    end

    # {line, lines} = add_to_line(word, line, width + String.length(word) + 1, lines)
    # render_words(tail, line, lines)
  end
  def render_words([], line, lines), do: {line, lines}

  # def add_to_line(word, %Line{max: max}=line, new_width, lines) when new_width >= max do
  #   add_to_line(word, %Line{max: max}, 0, [line|lines])
  # end
  # def add_to_line(word, %Line{instructions: instructions}=line, new_width, lines) do
  #   {%{line|instructions: [{&print/1, "#{word} "}|instructions], width: new_width}, lines}
  # end

  def print(str), do: str |> String.to_char_list |> Enum.each(fn ch -> :cecho.addch(ch) end)

  def attr_on(id), do: :cecho.attron(id <<< 8)

  def attr_off(id), do: :cecho.attroff(id <<< 8)
end
