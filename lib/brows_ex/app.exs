defmodule BrowsEx.App do
  def run(url) do
    ExNcurses.initscr
    ExNcurses.start_color
    ExNcurses.cbreak
    do_run(url, 1)
    ExNcurses.endwin
  end

  def do_run(url, highlight) do
    ExNcurses.clear
    title = "BrowsEx"
    print_title("#{title} - #{url}")
    
    tree =
      url
      |> BrowsEx.Requester.request
      |> BrowsEx.Parser.parse
      |> BrowsEx.Indexer.index("a")

    tree
    |> BrowsEx.Renderer.render(highlight)
    |> ExNcurses.printw
    # |> IO.puts

    wait_for_input(url, highlight, tree)
    # handle_char(?j, url, highlight, tree)
    # handle_char(?l, url, highlight, tree)
  end

  def wait_for_input(url, highlight, tree) do
    ExNcurses.keypad
    ExNcurses.flushinp

    char = ExNcurses.getchar

    char |> handle_char(url, highlight, tree)
  end

  def print_title(string), do: ExNcurses.printw(string)

  def handle_char(?j, url, highlight, tree), do: do_run(url, highlight + 1)
  def handle_char(?k, url, highlight, tree), do: do_run(url, highlight - 1)
  def handle_char(?l, url, highlight, tree), do: do_click(highlight, tree, url) # TODO wrong index
  def handle_char(?q, url, highlight, tree), do: nil
  def handle_char(_, url, highlight, tree), do: wait_for_input(url, highlight, tree)

  def do_click(index, tree, current_url) do
    url =
      tree
      # |> IO.inspect
      |> Floki.find("[brows_ex_index=#{index}]")
      # |> IO.inspect
      |> List.first
      |> Floki.attribute("href")
      |> List.first
      |> BrowsEx.Requester.transform_url(current_url)
      |> do_run(1)
  end
end

BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
