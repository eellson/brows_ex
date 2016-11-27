defmodule BrowsEx.App do
  alias BrowsEx.{Page, Line}

  def run(url) do
    init_cursor
    init_renderer
    get_and_render_page(url)
    term_renderer
  end

  def get_and_render_page(url) do
    cursor = reset_cursor
    tree = get_tree(url)
    page = get_page(tree, cursor)

    render(url, page, cursor)

    wait_for_input(url, tree, page)
  end

  def get_tree(url), do: url |> BrowsEx.Requester.request |> BrowsEx.Parser.parse

  def get_page(tree, {page, _link}) do
    tree
    |> BrowsEx.Paginator.paginate
    |> Enum.find(fn %BrowsEx.Page{index: index} -> index == page end)
  end

  def wait_for_input(url, tree, page) do
    char = :cecho.getch

    char |> handle_char(url, tree, page)
  end

  def handle_char(?j, url, tree, page) do
    cursor = next_link(page)
    page = get_page(tree, cursor)
    render(url, page, cursor)
    wait_for_input(url, tree, page)
  end
  def handle_char(?k, url, tree, page) do
    cursor = prev_link
    page = get_page(tree, cursor)
    render(url, page, cursor)
    wait_for_input(url, tree, page)
  end
  def handle_char(?l, url, tree, page), do: do_click(url, page)
  def handle_char(?r, url, tree, page), do: get_and_render_page(url)
  def handle_char(?q, url, tree, page), do: nil
  def handle_char(?p, url, tree, page) do
    cursor = prev_page
    page = get_page(tree, cursor)
    render(url, page, cursor)
    wait_for_input(url, tree, page)
  end
  def handle_char(?n, url, tree, page) do
    cursor = next_page
    page = get_page(tree, cursor)
    render(url, page, cursor)
    wait_for_input(url, tree, page)
  end
  def handle_char(_, url, tree, page), do: wait_for_input(url, tree, page)

  def do_click(current_url, %Page{lines: lines}) do
    {_current_page, link} = BrowsEx.Cursor.current
    target = lines |> Enum.find_value(fn %Line{instructions: instructions} ->
      Enum.find_value(instructions, fn
        {:start_link, ^link, target} -> target
        _ -> false
      end)
    end)


    target
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

  defp next_link(page), do: BrowsEx.Cursor.next(page)

  defp prev_link, do: BrowsEx.Cursor.prev

  defp next_page, do: BrowsEx.Cursor.next_page

  defp prev_page, do: BrowsEx.Cursor.prev_page

  defp init_renderer, do: BrowsEx.Renderer.init

  defp term_renderer, do: BrowsEx.Renderer.term

  defp render(url, page, cursor), do: BrowsEx.Renderer.render(url, page, cursor)
end

# BrowsEx.App.run("https://news.ycombinator.com/")
# BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
# BrowsEx.App.run("https://en.m.wikipedia.org/wiki/Big_Bay_Boom")
# BrowsEx.App.run("https://notes.eellson.com")
# BrowsEx.App.run("https://www.theguardian.com/uk")
