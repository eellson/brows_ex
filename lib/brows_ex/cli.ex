defmodule BrowsEx.CLI do
  def main(argv) do
    {options, _, _} = OptionParser.parse(argv,
      switches: [url: :string]
    )

    options[:url] |> BrowsEx.App.run
  end
end
