defmodule JSONReaderTest do
  use ExUnit.Case
  import ElixirExchange.JSONReader

  doctest ElixirExchange.JSONReader

  test "Passing a file should return a JSON" do
    json = get_json(Path.join("#{:code.priv_dir(:elixir_exchange)}","input_1.json"))

    assert json != nil
  end

  test "Should return error when read none exist file" do
    {result, _} = get_json("non exist file.json")
    assert result == :error
  end
end
