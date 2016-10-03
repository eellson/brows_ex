defmodule BrowsEx.Requester do
  def request(url), do: get(url)

  def get(url) do
    {:ok, response} = HTTPoison.get url
    response.body
  end
end
