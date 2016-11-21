defmodule BrowsEx.Cursor do
  def new, do: Agent.start_link(fn -> 1 end, name: __MODULE__)

  def current, do: Agent.get(__MODULE__, &(&1))

  def next, do: Agent.get_and_update(__MODULE__, &({&1+1, &1+1}))

  def prev, do: Agent.get_and_update(__MODULE__, &({&1-1, &1-1}))

  def reset, do: Agent.get_and_update(__MODULE__, fn _ -> {1, 1} end)
end
