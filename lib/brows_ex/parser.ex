defmodule BrowsEx.Parser do
  @spec parse(binary) :: list
  def parse(input) do
    {:ok, tokens, _} = input |> to_char_list |> :html_lexer.string
    {:ok, list} = tokens |> :html_parser.parse
    list
  end
end
