defmodule BrowsEx.IndexerTest do
  use ExUnit.Case, async: true
  alias BrowsEx.Indexer

  test "adds index to attributes" do
    html = {"ul", [], [{
             "li", [], [{
               "p", [], ["Sentence with a ", {
                 "a", [], ["link"]},
                 "."]}]},
            {"li", [], [{
               "p", [], [{"a", [], ["text"]}, {"a", [], ["text"]}]},{
             "a", [], ["text"]}]}]}

    assert html |> Indexer.index("a") == {{"ul", [],
      [{"li", [],
        [{"p", [], ["Sentence with a ", {"a", [{"brows_ex_index", 1}], ["link"]}, "."]}]},
       {"li", [],
        [{"p", [],
          [{"a", [{"brows_ex_index", 2}], ["text"]}, {"a", [{"brows_ex_index", 3}], ["text"]}]},
         {"a", [{"brows_ex_index", 4}], ["text"]}]}]}, 4}
  end
end
