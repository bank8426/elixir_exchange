defmodule JSONReaderTest do
  use ExUnit.Case
  import ElixirExchange.JSONReader
  import Mock

  doctest ElixirExchange.JSONReader

  test "Passing a file should return a JSON" do
    json = get_json(Path.join("#{:code.priv_dir(:elixir_exchange)}","input_1.json"))

    assert json != nil
  end
end
