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

  def traverse({name, _, _}, acc, _fun, _post) when name in @no_render, do: acc
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
  def traverse(_any, acc, _fun, _post), do: acc

  def into_lines({"h1", _attrs, _children}, lines) do
    new_line(lines, %{instructions: [{&attr_on/1, 1}]})
  end
  def into_lines({"a", attrs, _children}, [line|rest]) do
    line = new_instruction(line, {&attr_on/1, 2})
    [line|rest]
  end
  def into_lines({"li", _attrs, _children}, lines) do
    new_line(lines, %{instructions: [{&print/1, "* "}]})
  end
  def into_lines({name, attrs, children}, lines) when name in @block_level do
    new_line(lines, %{})
  end
  def into_lines({name, _attrs, _children}, lines), do: lines
  def into_lines(<<leaf::binary>>, lines), do: leaf |> String.split |> render_words(lines)

  def after_children({"h1", _attrs, _children}, [line|rest]) do
    line = new_instruction(line, {&attr_off/1, 1})
    [line|rest]
  end
  def after_children({"a", _attrs, _children}, [line|rest]) do
    line = new_instruction(line, {&attr_off/1, 2})
    [line|rest]
  end
  def after_children(_, lines), do: lines

  def render_words([], lines), do: lines
  def render_words(words, []), do: render_words(words, new_line)
  def render_words([word|tail], [%Line{width: width, max: max, instructions: instructions}=line|rest]=lines) do
    case String.length(word) + width do
      new_width when new_width >= max ->
        render_words([word|tail], new_line)
      new_width ->
        line = new_word(line, word, width)
        render_words(tail, [line|rest])
    end
  end

  def new_line(lines \\ [], attrs \\ %{})
  def new_line([], attrs) do
    {_height, width} = :cecho.getmaxyx
    new_line([%Line{max: width}], attrs)
  end
  def new_line([%Line{max: max}|_]=lines, attrs) do
    attrs = attrs |> Map.put(:max, max)
    [struct(Line, attrs)|lines]
  end

  def new_instruction(%Line{instructions: instructions}=line, instruction) do
    %{line|instructions: [instruction|instructions]}
  end

  def new_word(%Line{instructions: instructions}=line, word, width) do
    %{line|instructions: [{&print/1, "#{word} "}|instructions], width: width}
  end

  def print(str), do: str |> String.to_char_list |> Enum.each(fn ch -> :cecho.addch(ch) end)

  def attr_on(id), do: :cecho.attron(id <<< 8)

  def attr_off(id), do: :cecho.attroff(id <<< 8)
end
