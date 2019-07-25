defmodule JSONWriterTest do
  use ExUnit.Case
  import ElixirExchange.JSONWriter

  doctest ElixirExchange.JSONWriter

  test "Passing a Map should should parse to JSON and write to output file" do
    mock_data = %{
      buy: [%{price: 90.394, volume: 3.445}],
      sell: [%{price: 100.003, volume: 2.4}]
    }
    result = write_json_output(mock_data)

    assert result == :ok
  end
end
