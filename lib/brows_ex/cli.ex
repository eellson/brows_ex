defmodule BrowsEx.CLI do
  def main(argv) do
    {options, _, _} = OptionParser.parse(argv,
      switches: [url: :string]
    )

    html = """
    <html>
      <head>
        <title>Hello, world</title>
      </head>
      <body>
        <h1>Hello world</h1>
        <p>OK, let's see if we can successfully <em>parse</em> this.</p>
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
    """

    html
    |> BrowsEx.Parser.parse
    |> BrowsEx.Renderer.render
  end
end
