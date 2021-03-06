# BrowsEx

BrowsEx is a toy TUI browser, mostly built as a bit of fun.

**I'd recommend you don't use this to browse the web unless you trust the urls
you're hitting.**

[![asciicast](https://asciinema.org/a/4dqzbj0ws1osllpdwialol347.png)](https://asciinema.org/a/4dqzbj0ws1osllpdwialol347)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `brows_ex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:brows_ex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `brows_ex` is started before your application:

    ```elixir
    def application do
      [applications: [:brows_ex]]
    end
    ```

## TODO

- [ ] Handle gzipped reqs better.
  * Currently we naively unzip these, unsure if that's wise (https://github.com/benoitc/hackney/issues/155)
- [ ] SSL verification.
- [ ] Fill out test suite.
- [ ] Better documentation, specs, types.
- [ ] Handle forms/inputs.
- [ ] History/back functionality.
