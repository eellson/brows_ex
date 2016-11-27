defmodule BrowsEx.Cursor do
  alias BrowsEx.Page

  def new, do: Agent.start_link(fn -> {0, 0} end, name: __MODULE__)

  def current, do: Agent.get(__MODULE__, &(&1))

  def next(%Page{link_count: link_count}) do
    Agent.get_and_update(__MODULE__, fn
      {page, link} when link == link_count -> {{page + 1, 0}, {page + 1, 0}}
      {page, link} -> {{page, link + 1}, {page, link + 1}}
    end)
  end

  def prev do
    Agent.get_and_update(__MODULE__, fn
      {page, 0} -> {{page - 1, 0}, {page - 1, 0}}
      {page, link} -> {{page, link - 1}, {page, link - 1}}
    end)
  end

  def next_page do
    Agent.get_and_update(__MODULE__, fn {page, link} ->
      {{page + 1, 0}, {page + 1, 0}}
    end)
  end

  def prev_page do
    Agent.get_and_update(__MODULE__, fn {page, link} ->
      {{page - 1, 0}, {page - 1, 0}}
    end)
  end

  def reset, do: Agent.get_and_update(__MODULE__, fn _ -> {{0,0}, {0,0}} end)
end
