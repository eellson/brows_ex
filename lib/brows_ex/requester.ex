defmodule BrowsEx.Requester do
  def request(url), do: get(url)

  def get(url) do
    {:ok, response} =
      url
      |> HTTPoison.get

    response
    # |> IO.inspect
    |> handle_response
  end

  def transform_url(url, base) do
    base
    |> URI.parse
    |> URI.merge(url)
    |> to_string
  end

  defp handle_response(%HTTPoison.Response{headers: headers} = response) do
    headers |> Enum.any?(&gzipped?(&1)) |> handle_zipped(response)
  end

  def gzipped?({"Content-Encoding", "gzip"}), do: true
  def gzipped?(_), do: false

  def handle_zipped(true, response), do: response.body |> :zlib.gunzip
  def handle_zipped(false, response), do: response.body
end
