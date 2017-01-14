defmodule BrowsEx.PaginatorTest do
  use ExUnit.Case, async: true
  alias BrowsEx.{Paginator, Line}

  describe "traverse/4" do
    test "walks tree depth first" do
      tree = {:root, [], [
               {:first_child, [], [{:nested_child, [], []}]},
               {:second_child, [], []}]}

      result = Paginator.traverse(tree, [],
                 fn {name, _, _}, acc -> [name|acc] end,
                 fn thing, acc -> acc end)
      assert [:root, :first_child, :nested_child, :second_child] ==
        result |> Enum.reverse
    end # walks tree, applying fun and post per node

    test "applies fun before children, post after children" do
      tree = {:root, [], [
               {:first_child, [], [{:nested_child, [], []}]},
               {:second_child, [], []}]}

      result = Paginator.traverse(tree, [],
                 fn {name, _, _}, acc -> ["#{name}_start"|acc] end,
                 fn {name, _, _}, acc -> ["#{name}_end"|acc] end)

      assert ["root_start", "first_child_start", "nested_child_start",
              "nested_child_end", "first_child_end", "second_child_start",
              "second_child_end", "root_end"] == result |> Enum.reverse
    end # applies fun before children, post after children

    test "applies function to leaf nodes" do
      tree = {:root, [], ["text"]}

      result = Paginator.traverse(tree, [],
                 fn
                   {name, _, _}, acc -> [{:before, name}|acc]
                   leaf, acc when is_binary(leaf) -> [{:before, leaf}|acc]
                 end,
                 fn
                   {name, _, _}, acc -> [{:after, name}|acc]
                   leaf, acc when is_binary(leaf) -> [{:after, leaf}|acc]
                 end)

      assert [before: :root, before: "text", after: "text", after: :root] ==
        result |> Enum.reverse
    end # applies function to leaf nodes

    test "returns unchanged accumulator for unrecognised nodes" do
      tree = {:root, [], [{:ignore_me, []}]}

      result = Paginator.traverse(tree, [],
                 fn {name, _, _}, acc -> [name|acc] end,
                 fn thing, acc -> acc end)

      assert [:root] = result |> Enum.reverse
    end # returns unchanged accumulator for unrecognised nodes
  end # traverse/4

  describe "render_words/2" do
    test "prepends to new line if no existing lines" do
      lines = Paginator.render_words(["123456789"], [])

      assert [%Line{width: 10, max: 10, instructions: [{:print, "123456789 "}]}] ==
        lines
    end # prepends to new line if no existing lines

    test "prepends to existing line if space" do
      lines = Paginator.render_words(["123456789"], [%Line{max: 10}])

      assert [%Line{width: 10, max: 10, instructions: [{:print, "123456789 "}]}] ==
        lines
    end # prepends to existing line if space

    test "prepends to new line if no space in current" do
      lines = Paginator.render_words(["123456789"], [%Line{max: 10, width: 1}])

      assert [%Line{width: 10, max: 10, instructions: [{:print, "123456789 "}]},
              %Line{instructions: [], max: 10, width: 1}] == lines
    end # prepends to new line if no space in current

    test "handles many words/lines" do
      lines = Paginator.render_words(["123456789", "1", "2345678", "123", "456", "7"], [])

      assert [%Line{instructions: [print: "123456789 "], max: 10, width: 10},
              %Line{instructions: [print: "2345678 ", print: "1 "], max: 10, width: 10},
              %Line{instructions: [print: "7 ", print: "456 ", print: "123 "], max: 10, width: 10}] ==
        lines |> Enum.reverse
    end

    @tag :pending
    test "splits word that is longer than max width" do
    end # splits word that is longer than max width
  end # render_words/2

end
