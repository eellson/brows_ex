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
    tree |> traverse([], &into_lines(&1, &2), &after_children(&1, &2))
  end

  def traverse({name, _attrs, _children}, acc, _fun, _post) when name in @no_render do
    acc
  end
  def traverse({_name, _attrs, children}=node, acc, fun, post) do
    acc = fun.(node, acc)
    acc = traverse(children, acc, fun, post)
    post.(node, acc)
  end
  def traverse([child|siblings], acc, fun, post) do
    acc = traverse(child, acc, fun, post)
    traverse(siblings, acc, fun, post)
  end
  def traverse(<<leaf::binary>>, acc, fun, post) do
    acc = fun.(leaf, acc)
    post.(leaf, acc)
  end
  def traverse(_else, acc, _fun, _post) do
    acc
  end

  def into_lines({"h1", _attrs, _children}, lines) do
    # {_height, width} = :cecho.getmaxyx
    {_height, width} = {10, 80}
    [%Line{max: width, instructions: [{&attr_on/1, 1}]}|lines]
  end
  def into_lines({"a", attrs, _children}, [%Line{instructions: instructions}=line|rest]) do
    [%{line|instructions: [{&attr_on/1, 2}|instructions]}|rest]
  end
  def into_lines({"li", _attrs, _children}, lines) do
    {_height, width} = {10, 80}
    [%Line{max: width, instructions: [{&print/1, "* "}]}|lines]
  end
  def into_lines({name, attrs, children}, lines) when name in @block_level do
    # {_height, width} = :cecho.getmaxyx
    {_height, width} = {10, 80}
    [%Line{max: width}|lines]
  end
  def into_lines({name, _attrs, _children}, lines), do: lines
  def into_lines(<<leaf::binary>>, lines), do: leaf |> String.split |> render_words(lines)

  def after_children({"h1", _attrs, _children}, [%Line{instructions: instructions}=line|rest]) do
    [%{line|instructions: [{&attr_off/1, 1}|instructions]}|rest]
  end
  def after_children({"a", _attrs, _children}, [%Line{instructions: instructions}=line|rest]) do
    [%{line|instructions: [{&attr_off/1, 2}|instructions]}|rest]
  end
  def after_children(_, lines), do: lines

  def render_words([], lines), do: lines
  def render_words(words, []) do
    # {_height, width} = :cecho.getmaxyx
    {_height, width} = {10, 80}
    # {_height, width} = {9, 80}
    render_words(words, [%Line{max: width}])
  end
  def render_words([word|tail], [%Line{width: width, max: max, instructions: instructions}=line|rest]=lines) do
    # IO.inspect word
    # IO.inspect lines
    case String.length(word) + width do
      new_width when new_width >= max ->
        render_words([word|tail], [%Line{max: max}|lines])
      new_width ->
        render_words(tail, [%{line|width: new_width + 1, instructions: [{&print/1, "#{word} "}|instructions]}|rest])
    end
  end

  def print(str), do: str |> String.to_char_list |> Enum.each(fn ch -> :cecho.addch(ch) end)

  def attr_on(id), do: :cecho.attron(id <<< 8)

  def attr_off(id), do: :cecho.attroff(id <<< 8)
end
