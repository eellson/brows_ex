defmodule BrowsEx.App do
  def run(url) do
    init_ncurses
    get_and_render_page(url)
    term_ncurses
  end

  def init_ncurses do
    :application.start(:cecho)
    :cecho.start_color
    :cecho.init_pair(4, 4, 0) # blue
    :cecho.init_pair(5, 5, 0) # purple
    :cecho.cbreak
  end

  def term_ncurses do
    :application.stop(:cecho)
    System.halt
  end

  def get_and_render_page(url, highlight \\ 1) do
    url
    |> get_tree
    |> render(highlight)
  end

  def get_tree(url) do
    tree =
      url
      |> BrowsEx.Requester.request
      |> BrowsEx.Parser.parse
      |> BrowsEx.Indexer.index("a")

    {url, tree}
  end

  def render({url, tree}, highlight \\ 1) do
    :cecho.erase

    print_title("BrowsEx = #{url}")

    tree
    |> BrowsEx.Renderer.render(highlight)

    :cecho.refresh

    wait_for_input({url, tree}, highlight)
  end

  def print_title(string) do
    string
    |> BrowsEx.Renderer.print
  end

  def wait_for_input({url, tree}, highlight) do
    char = :cecho.getch

    char |> handle_char({url, tree}, highlight)
  end

  def handle_char(?j, {url, tree}, highlight), do: render({url, tree}, highlight + 1)
  def handle_char(?k, {url, tree}, highlight), do: render({url, tree}, highlight - 1)
  def handle_char(?l, {url, tree}, highlight), do: do_click({url, tree}, highlight)
  def handle_char(?r, {url, tree}, highlight), do: get_and_render_page(url)
  def handle_char(?q, {url, tree}, highlight), do: nil
  def handle_char(_, {url, tree}, highlight), do: wait_for_input({url, tree}, highlight)

  def do_click({current_url, tree}, index) do
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
