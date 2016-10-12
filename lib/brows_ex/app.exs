defmodule BrowsEx.App do
  def run(url) do
    init_ncurses
    get_and_render_page(url)
    term_ncurses
  end

  def init_ncurses do
    ExNcurses.initscr
    ExNcurses.start_color
    ExNcurses.cbreak
  end

  def term_ncurses, do: ExNcurses.endwin
  
  def get_and_render_page(url, highlight \\ 1) do
    url
    |> get_tree
    |> render(highlight)
  end

  def get_tree(url) do
    # tree = 
    #   url
    #   |> BrowsEx.Requester.request
    #   |> BrowsEx.Parser.parse
    #   |> BrowsEx.Indexer.index("a")
      # |> IO.inspect
    
    tree = """
    <html>
      <head>
        <title>Hello, world</title>
      </head>
      <body>
        <h1>Hello <a href="#">world</a></h1>
        <p>OK, let's <a href="#">see</a> if <a href="#">we</a> can successfully <em>parse</em> this.</p>
        <p>k still works</p>
        <div>
          <h2>ok, so <small>what</small></h2>
          <p>Kinda just checking this shit works</p>
          <ul>
            <li>umm</li>
            <li>yeah</li>
          </ul>
        </div>
        <div>
          <p><strong>OK SO SERIOUSLY</strong> this thing seems to kinda work</p>
        </div>
      </body>
    </html>
    """ |> BrowsEx.Parser.parse |> BrowsEx.Indexer.index("a")

    {url, tree}
  end

  def render({url, tree}, highlight \\ 1) do
    # ExNcurses.clear
    # print_title("BrowsEx = #{url}")

    tree
    |> IO.inspect
    |> BrowsEx.Renderer.render(highlight)
    # |> IO.inspect
    # |> ExNcurses.printw

    ExNcurses.refresh

    wait_for_input({url, tree}, highlight)
  end

  def print_title(string), do: ExNcurses.printw(string)

  def wait_for_input({url, tree}, highlight) do
    ExNcurses.keypad
    ExNcurses.flushinp

    char = ExNcurses.getchar

    char |> handle_char({url, tree}, highlight)
  end

  def handle_char(?j, {url, tree}, highlight), do: render({url, tree}, highlight + 1)
  def handle_char(?k, {url, tree}, highlight), do: render({url, tree}, highlight - 1)
  def handle_char(?l, {url, tree}, highlight), do: do_click({url, tree}, highlight)
  def handle_char(?q, {url, tree}, highlight), do: nil
  def handle_char(_, {url, tree}, highlight), do: wait_for_input({url, tree}, highlight)

  def do_click({current_url, tree}, index) do
    tree
    # |> IO.inspect
    |> Floki.find("[brows_ex_index=#{index}]")
    # |> IO.inspect
    |> List.first
    |> Floki.attribute("href")
    |> List.first
    |> BrowsEx.Requester.transform_url(current_url)
    |> get_and_render_page
  end
end

BrowsEx.App.run("https://en.wikipedia.org/wiki/Main_Page")
