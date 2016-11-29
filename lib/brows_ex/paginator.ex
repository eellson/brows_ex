defmodule BrowsEx.Paginator do
  alias BrowsEx.{Line, Page}
  use Bitwise

  @no_render ~w(head script)
  @block_level ~w(address article aside blockquote canvas dd div dl fieldset
    figcaption figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr li main nav
    noscript ol output p pre section table tfoot ul video tr)

  def paginate(tree) do
    tree |> traverse([], &into_lines(&1, &2), &after_children(&1, &2)) |> into_pages
  end

  @doc """
  Walks the tree (depth-first), building up an accumulator by recursively
  applying `fun` to each node, and then applying `post` once walking back up
  to a node.

  Does not apply `fun` or `post` to `List`s of children.
  """
  @spec traverse(node :: tuple | list | String.t, acc :: term, fun :: fun, post :: fun) :: term
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

  @doc """
  Handles nodes being passed from `traverse`, returning transformed accumulator.

  Called before `traverse/4` continues with children (if any), this function
  handles inserting element-specific information into lines. For instance:

  * h1 -> insert {:start_h1} into new line
  * a -> insert {:start_link, :id, target} into current line
  * li -> insert {:print, "* "} into new line
  * text -> handled in `render_words/2`
  """
  @spec into_lines(node :: tuple | String.t, lines :: list) :: list
  def into_lines({"h1", _attrs, _children}, lines) do
    new_line(lines, %{instructions: [{:start_h1}]})
  end
  def into_lines({"a", _attrs, _children}=node, [line|rest]) do
    target = node |> Floki.attribute("href") |> List.first

    line = new_instruction(line, {:start_link, :id, target})
    [line|rest]
  end
  def into_lines({"li", _attrs, _children}, lines) do
    new_line(lines, %{instructions: [{:print, "* "}]})
  end
  def into_lines({name, _attrs, _children}, lines) when name in @block_level do
    new_line(lines, %{})
  end
  def into_lines({_name, _attrs, _children}, lines), do: lines
  def into_lines(<<leaf::binary>>, lines), do: leaf |> String.split |> render_words(lines)

  @doc """
  Handles nodes being passed from `traverse`, returning transformed accumulator.

  Called after traverse has walked children (if any), this function handles
  inserting newlines after most block level elements, and indicators that a
  particular element is closed.
  """
  @spec after_children(node :: tuple | any, lines :: list) :: list
  def after_children({"h1", _attrs, _children}, [line|rest]) do
    line = new_instruction(line, {:end_h1})
    [line|rest]
  end
  def after_children({"a", _attrs, _children}, [line|rest]) do
    line = new_instruction(line, {:end_link})
    [line|rest]
  end
  def after_children({"li", _attrs, _children}, lines), do: lines
  def after_children({name, _attrs, _children}, lines) when name in @block_level do
    new_line(lines, %{})
  end
  def after_children(_, lines), do: lines

  @doc """
  Splits string into List of words, inserting into `%Line{}`s.

  Will insert into first Line in list if it has room, else will create a new
  Line to add to.
  """
  @spec render_words(words :: list, lines :: list) :: list
  def render_words([], lines), do: lines
  def render_words(words, []), do: render_words(words, new_line)
  def render_words([word|tail], [%Line{width: width, max: max}=line|rest]=lines) do
    case String.length(word) + width do
      new_width when new_width >= max ->
        render_words([word|tail], new_line(lines))
      new_width ->
        line = new_word(line, word, new_width)
        render_words(tail, [line|rest])
    end
  end

  @doc """
  Prepends a new `%Line{}` to `lines`.

  If passed in a map of attrs, these will populate the created `%Line`.
  """
  @spec new_line(lines :: list, attrs :: map) :: list
  def new_line(lines \\ [], attrs \\ %{})
  def new_line([], attrs) do
    {_height, width} = :cecho.getmaxyx
    [%{struct(Line, attrs)|max: width}]
  end
  def new_line([%Line{max: max}|_]=lines, attrs) do
    attrs = attrs |> Map.put(:max, max)
    [struct(Line, attrs)|lines]
  end

  @doc """
  Prepends a new instruction to the given `%Line{}`.
  """
  @spec new_instruction(line :: struct, instruction :: tuple) :: struct
  def new_instruction(%Line{instructions: instructions}=line, instruction) do
    %{line|instructions: [instruction|instructions]}
  end

  @doc """
  Prepends a new print instruction to the given `%Line{}`, and updates line's
  `width` with new value.
  """
  @spec new_word(line :: struct, word :: String.t, width :: integer) :: struct
  def new_word(%Line{instructions: instructions}=line, word, width) do
    %{line|instructions: [{:print, "#{word} "}|instructions], width: width + 1}
  end

  @doc """
  Transforms list of lines into list of pages.

  Once we have a list of `%Page{}` structs we index the links for each page, and
  index the pages themselves.
  """
  @spec into_pages(lines :: list) :: list
  def into_pages(lines) do
    {height, _width} = :cecho.getmaxyx

    {pages, _count} =
      lines
      |> Enum.reduce([], &dedup_empty_lines(&1, &2))
      |> Enum.map(fn line -> Map.update!(line, :instructions, &(Enum.reverse(&1))) end)
      |> Enum.chunk(height, height, [])
      |> Enum.map(fn chunk -> %Page{lines: chunk} end)
      |> Enum.map(&Page.index_links/1)
      |> Enum.map_reduce(0, fn(page, count) -> {%{page|index: count}, count + 1} end)

    pages
  end

  defp dedup_empty_lines(%Line{width: 0}, []), do: []
  defp dedup_empty_lines(line, []), do: [line]
  defp dedup_empty_lines(%Line{width: 0}, [%Line{width: 0}|_]=acc), do: acc
  defp dedup_empty_lines(line, acc), do: [line|acc]
end
