defmodule BrowsEx.App do
  def run(url) do
    init_cursor
    init_ncurses
    get_and_render_page(url)
    term_ncurses
  end

  def init_cursor, do: BrowsEx.Cursor.new

  def init_ncurses do
    :application.start(:cecho)
    :cecho.start_color
    :cecho.init_pair(1, 1, 0) # red
    :cecho.init_pair(2, 2, 0) # green
    :cecho.init_pair(3, 3, 0) # yellow
    :cecho.init_pair(4, 4, 0) # blue
    :cecho.init_pair(5, 5, 0) # purple
    :cecho.init_pair(6, 6, 0) # cyan
    :cecho.init_pair(7, 7, 0) # white
    :cecho.init_pair(8, 8, 0) # grey
    :cecho.cbreak
  end

  def term_ncurses do
    :application.stop(:cecho)
    System.halt
  end

  def get_and_render_page(url, page \\ 0) do
    BrowsEx.Cursor.reset

    tree = url |> get_tree

    render(url, tree)

    wait_for_input(url, tree, page)
  end

  def get_tree(url, page \\ 0) do
    tree =
      url
      |> BrowsEx.Requester.request
      # |> get_h1s
      |> BrowsEx.Parser.parse
      |> BrowsEx.Indexer.index("a")
  end

  def render(url, tree, page \\ 0) do
    :cecho.erase

    # print_title("BrowsEx = #{url}")

    tree
    |> BrowsEx.Paginator.paginate
    |> Enum.at(page)
    |> Enum.map(fn line ->
         line.instructions
         |> Enum.map(fn {func, arg} ->
           func.(arg)
         end)
         :cecho.addch(?\n)
       end)

    :cecho.refresh
  end

  def print_title(string) do
    string
    |> BrowsEx.Renderer.print
  end

  def wait_for_input(url, tree, page) do
    char = :cecho.getch

    char |> handle_char(url, tree, page)
  end

  def handle_char(?j, url, tree, page) do
    BrowsEx.Cursor.next
    render(url, tree, page)
    wait_for_input(url, tree, page)
  end
  def handle_char(?k, url, tree, page) do
    BrowsEx.Cursor.prev
    render(url, tree, page)
    wait_for_input(url, tree, page)
  end
  def handle_char(?l, url, tree, page), do: do_click(url, tree)
  def handle_char(?r, url, tree, page), do: get_and_render_page(url)
  def handle_char(?q, url, tree, page), do: nil
  def handle_char(?p, url, tree, page) do
    render(url, tree, page - 1)
    wait_for_input(url, tree, page - 1)
  end
  def handle_char(?n, url, tree, page) do
    render(url, tree, page + 1)
    wait_for_input(url, tree, page + 1)
  end
  def handle_char(_, url, tree, page), do: wait_for_input(url, tree, page)

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
end

BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
