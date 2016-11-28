defmodule BrowsEx.Cursor do
  alias BrowsEx.Page

  def new, do: Agent.start_link(fn -> {0, 0} end, name: __MODULE__)

  def current, do: Agent.get(__MODULE__, &(&1))

  def next_link(%Page{link_count: links_on_page}, %Page{index: last_page}) do
    Agent.get_and_update(__MODULE__, fn
      {^last_page, link} when link >= links_on_page -> {{last_page, link}, {last_page, link}}
      {page, link} when link >= links_on_page -> {{page + 1, 0}, {page + 1, 0}}
      {page, link} -> {{page, link + 1}, {page, link + 1}}
    end)
  end

  def prev_link(page) do
    Agent.get_and_update(__MODULE__, fn
      {0, 0} -> {0, 0}
      {0, link} -> {{0, link - 1}, {0, link - 1}}
      {page_index, 0} -> {{page_index - 1, page.link_count}, {page_index - 1, page.link_count}}
      {page_index, link} -> {{page_index, link - 1}, {page_index, link - 1}}
    end)
  end

  def next_page(%Page{index: last_page, link_count: last_link}) do
    Agent.get_and_update(__MODULE__, fn
      {^last_page, _link} -> {{last_page, last_link}, {last_page, last_link}}
      {page, _link} -> {{page + 1, 0}, {page + 1, 0}}
    end)
  end

  def prev_page do
    Agent.get_and_update(__MODULE__, fn
      {0, _link} -> {{0, 0}, {0, 0}}
      {page, _link} -> {{page - 1, 0}, {page - 1, 0}}
    end)
  end

  def reset, do: Agent.get_and_update(__MODULE__, fn _ -> {{0,0}, {0,0}} end)
end
