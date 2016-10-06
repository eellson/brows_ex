defmodule BrowsEx.Requester do
  def request(url), do: get(url)

  def get(url) do
    {:ok, response} = HTTPoison.get url

    response
    |> IO.inspect
    |> handle_response
  end

  defp handle_response(%HTTPoison.Response{headers: headers} = response) do
    headers |> Enum.any?(&gzipped?(&1)) |> handle_zipped(response)
  end

  def gzipped?({"Content-Encoding", "gzip"}), do: true
  def gzipped?(_), do: false

  def handle_zipped(true, response), do: response.body |> :zlib.gunzip
  def handle_zipped(false, response), do: response.body
end
