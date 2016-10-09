defmodule BrowsEx.Indexer do
  @doc """
  Adds an `{"brows_ex_index", i}` item to attributes for nodex matching selector.
  """
  @spec index(tuple, String.t) :: tuple
  def index(tree, selector), do: index(tree, selector, 0)

  def index({name, attributes, children} = focus, selector, count) when name == selector do
    attributes = [{"brows_ex_index", count + 1}|attributes]
    {children, new_count} = index(children, selector, count + 1)

    {{name, attributes, children}, new_count}
  end
  def index({name, attributes, children} = focus, selector, count) do
    {children, new_count} = index(children, selector, count)

    {{name, attributes, children}, new_count}
  end
  def index([head|tail] = focus, selector, count) do
    {head, new_count} = index(head, selector, count)
    {tail, new_count} = index(tail, selector, new_count)

    {[head|tail], new_count}
  end
  def index(anything, selector, count) do
    {anything, count}
  end
end
