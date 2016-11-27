defmodule BrowsEx.App do
  def run(url) do
    init_cursor
    init_renderer
    get_and_render_page(url)
    term_renderer
  end

  def get_and_render_page(url) do
    reset_cursor

    tree = url |> get_tree
    render(url, tree)

    wait_for_input(url, tree)
  end

  def get_tree(url, page \\ 0) do
    url
    |> BrowsEx.Requester.request
    # |> get_h1s
    |> BrowsEx.Parser.parse
    |> BrowsEx.Indexer.index("a")
  end

  def print_title(string) do
    string
    |> BrowsEx.Renderer.print
  end

  def wait_for_input(url, tree) do
    char = :cecho.getch

    char |> handle_char(url, tree)
  end

  def handle_char(?j, url, tree) do
    increment_cursor
    render(url, tree)
    wait_for_input(url, tree)
  end
  def handle_char(?k, url, tree) do
    decrement_cursor
    render(url, tree)
    wait_for_input(url, tree)
  end
  def handle_char(?l, url, tree), do: do_click(url, tree)
  def handle_char(?r, url, tree), do: get_and_render_page(url)
  def handle_char(?q, url, tree), do: nil
  def handle_char(?p, url, tree) do
    render_prev(url, tree)
    wait_for_input(url, tree)
  end
  def handle_char(?n, url, tree) do
    render_next(url, tree)
    wait_for_input(url, tree)
  end
  def handle_char(_, url, tree), do: wait_for_input(url, tree)

  def do_click(current_url, tree) do
    index = BrowsEx.Cursor.current |> Integer.to_string

    tree
    |> Floki.find("[brows_ex_index=#{index}]")
    |> List.first
    |> Floki.attribute("href")
    |> List.first
    |> BrowsEx.Requester.transform_url(current_url)
    |> get_and_render_page
  end

  def get_h1s(_) do
    # 1..1
    1..200
    |> Enum.map(fn i -> "<h1>#{i}</h1><p>Oh hi <em>m8</em>.</p><script>y not</script><!-- wtf -->" end)
    |> Enum.join
  end

  defp init_cursor, do: BrowsEx.Cursor.new

  defp reset_cursor, do: BrowsEx.Cursor.reset

  defp increment_cursor, do: BrowsEx.Cursor.next

  defp decrement_cursor, do: BrowsEx.Cursor.prev

  defp init_renderer, do: BrowsEx.Renderer.init

  defp term_renderer, do: BrowsEx.Renderer.term

  defp render(url, tree), do: BrowsEx.Renderer.render(url, tree)

  defp render_next(url, tree), do: BrowsEx.Renderer.render_next(url, tree)

  defp render_prev(url, tree), do: BrowsEx.Renderer.render_prev(url, tree)
end

# BrowsEx.App.run("https://news.ycombinator.com/")
# BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
# BrowsEx.App.run("https://en.m.wikipedia.org/wiki/Big_Bay_Boom")
# BrowsEx.App.run("https://notes.eellson.com")
# BrowsEx.App.run("https://www.theguardian.com/uk")
