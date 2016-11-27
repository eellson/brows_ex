defmodule BrowsEx.App do
  alias BrowsEx.{Page, Line, Paginator}

  def run(url) do
    init_cursor
    init_renderer
    get_and_render_page(url)
    term_renderer
  end

  def get_and_render_page(url) do
    pages = url |> get_tree |> Paginator.paginate

    cursor = reset_cursor
    page = get_page(pages, cursor)

    render(url, page, cursor)

    wait_for_input(url, pages, page)
  end

  def get_tree(url), do: url |> BrowsEx.Requester.request |> BrowsEx.Parser.parse

  def get_page(pages, {page, _link}) do
    Enum.find(pages, fn %BrowsEx.Page{index: index} -> index == page end)
  end

  def wait_for_input(url, pages, page) do
    char = :cecho.getch

    handle_char(char, url, pages, page)
  end

  def handle_char(?j, url, pages, page) do
    cursor = next_link(page)
    page = get_page(pages, cursor)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?k, url, pages, page) do
    cursor = prev_link
    page = get_page(pages, cursor)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?l, url, pages, page), do: do_click(url, page)
  def handle_char(?r, url, pages, page), do: get_and_render_page(url)
  def handle_char(?q, url, pages, page), do: nil
  def handle_char(?p, url, pages, page) do
    cursor = prev_page
    page = get_page(pages, cursor)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?n, url, pages, page) do
    cursor = next_page
    page = get_page(pages, cursor)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(_, url, pages, page), do: wait_for_input(url, pages, page)

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
