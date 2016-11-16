defmodule Line do
  defstruct [width: 0, max: 0, instructions: []]
end

defmodule BrowsEx.RendererV2 do
  def render(tree) do
    {height, width} = {10, 40}
    # {height, width} = :cecho.getmaxyx
    {line, lines} = tree |> render_node(%Line{max: width}, [])

    [line|lines]
  end

  def render_node({"h1", attributes, children}, %Line{instructions: instructions}=line, lines) do
    {line, lines} =
      children
      |> render_node(%{line|instructions: [{&attr_on/1, 1}|instructions]}, lines)

    {%{line|instructions: [{&attr_off/1, 1}|line.instructions]}, lines}
  end

  def render_node({name, attributes, children}, line, lines) do
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

  def print(str), do: IO.puts str

  def attr_on(id), do: IO.puts "#{id} ON"

  def attr_off(id), do: IO.puts "#{id} OFF"
end
