defmodule BrowsEx.App do
  alias BrowsEx.{Page, Line, Paginator, Requester, Parser, Cursor, Renderer}

  def run(url) do
    init_cursor
    init_renderer
    get_and_render_page(url)
    term_renderer
  end

  def get_and_render_page(url) do
    pages = url |> get_tree |> Paginator.paginate
    {cursor, page} = reset_cursor |> get_current(pages)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end

  def get_tree(url), do: url |> Requester.request |> Parser.parse

  def get_current({page_index, _link}=cursor, pages) do
    page = Enum.find(pages, fn %Page{index: index} -> index == page_index end)

    {cursor, page}
  end

  def wait_for_input(url, pages, page) do
    :cecho.getch |> handle_char(url, pages, page)
  end

  def handle_char(?j, url, pages, page) do
    {cursor, page} = next_link(page) |> get_current(pages)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?k, url, pages, page) do
    {cursor, page} = prev_link |> get_current(pages)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?n, url, pages, page) do
    {cursor, page} = next_page |> get_current(pages)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?p, url, pages, page) do
    {cursor, page} = prev_page |> get_current(pages)

    render(url, page, cursor)
    wait_for_input(url, pages, page)
  end
  def handle_char(?l, url, pages, page), do: do_click(url, page)
  def handle_char(?r, url, pages, page), do: get_and_render_page(url)
  def handle_char(?q, url, pages, page), do: nil
  def handle_char(_, url, pages, page), do: wait_for_input(url, pages, page)

  def do_click(current_url, %Page{lines: lines}) do
    {_current_page, link} = Cursor.current
    target = lines |> Enum.find_value(fn %Line{instructions: instructions} ->
      Enum.find_value(instructions, fn
        {:start_link, ^link, target} -> target
        _ -> false
      end)
    end)


    target
    |> Requester.transform_url(current_url)
    |> get_and_render_page
  end

  def get_h1s(_) do
    # 1..1
    1..200
    |> Enum.map(fn i -> "<h1>#{i}</h1><p>Oh hi <em>m8</em>.</p><script>y not</script><!-- wtf -->" end)
    |> Enum.join
  end

  defp init_cursor, do: Cursor.new

  defp reset_cursor, do: Cursor.reset

  defp next_link(page), do: Cursor.next(page)

  defp prev_link, do: Cursor.prev

  defp next_page, do: Cursor.next_page

  defp prev_page, do: Cursor.prev_page

  defp init_renderer, do: Renderer.init

  defp term_renderer, do: Renderer.term

  defp render(url, page, cursor), do: Renderer.render(url, page, cursor)
end

# BrowsEx.App.run("https://news.ycombinator.com/")
# BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
# BrowsEx.App.run("https://en.m.wikipedia.org/wiki/Big_Bay_Boom")
# BrowsEx.App.run("https://notes.eellson.com")
# BrowsEx.App.run("https://www.theguardian.com/uk")
