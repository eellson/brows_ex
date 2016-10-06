defmodule BrowsEx.Parser do
  @spec parse(binary) :: list
  def parse(input) do
    input = """
    <html>
      <head>
        <title>Hello, world</title>
      </head>
      <body>
        <h1>Hello world</h1>
        <p>Pls <em>parse</em> me <a src="/" class="wtf">link</a>.</p>
      </body>
    </html>
    """
    # IO.inspect input
    {:ok, tokens, _} = input |> to_char_list |> :html_lexer.string
    # IO.inspect tokens
    {:ok, list} = tokens |> :html_parser.parse
    IO.inspect list
    # list |> parse_tag
  end

  def parse_tag({tag, children}) do
    {tag, attrs} = parse_start_tag(tag)

    {tag, attrs, parse_children(children)}
  end

  def parse_start_tag(tag), do: parse_start_tag(tag, '')

  def parse_start_tag([?<|t], acc), do: parse_start_tag(t, acc)
  def parse_start_tag([?>|[]], acc), do: {Enum.reverse(acc), []}
  def parse_start_tag([? |t], acc), do: {Enum.reverse(acc), parse_attributes(t, '')}
  def parse_start_tag([char|t], acc), do: parse_start_tag(t, [char|acc])

  # def parse_attributes([? |t], acc), do: parse_attributes(t, acc)
  def parse_attributes([?>|[]], acc), do: Enum.reverse(acc)
  def parse_attributes([char|t], acc), do: parse_attributes(t, [char|acc])

  def parse_children([]), do: []
  def parse_children([h|[]]) when is_tuple(h), do: [parse_tag(h)]
  def parse_children([h|[]]), do: [h]
  def parse_children([h|t]) when is_tuple(h), do: [parse_tag(h)|parse_children(t)]
  def parse_children([h|t]) when is_binary(h), do: [h|parse_children(t)]
end
