defmodule HelperTest do
  use ExUnit.Case
  import ElixirExchange.Helper

  doctest ElixirExchange.Helper

  test "Passing list should sort ascending by price" do
    mock_list = [
      %{"price" => 90.394, "volume" => 3.445},
      %{"price" => 89.394, "volume" => 4.3},
      %{"price" => 90.15, "volume" => 1.305}
    ]
    expected_list = [
      %{"price" => 89.394, "volume" => 4.3},
      %{"price" => 90.15, "volume" => 1.305},
      %{"price" => 90.394, "volume" => 3.445}
    ]
    ordered_list = sort_price_ascending(mock_list)

    assert ordered_list == expected_list
  end

  test "Passing list should sort descending by price" do
    mock_list = [
      %{"price" => 90.394, "volume" => 3.445},
      %{"price" => 89.394, "volume" => 4.3},
      %{"price" => 90.15, "volume" => 1.305}
    ]
    expected_list = [
      %{"price" => 90.394, "volume" => 3.445},
      %{"price" => 90.15, "volume" => 1.305},
      %{"price" => 89.394, "volume" => 4.3}
    ]
    ordered_list = sort_price_descending(mock_list)

    assert ordered_list == expected_list
  end

  test "Passing empty list to sort_price_ascending should return empty list" do
    mock_list = []
    expected_list = []
    ordered_list = sort_price_ascending(mock_list)

    assert ordered_list == expected_list
  end

  test "Passing empty list to sort_price_descending should return empty list" do
    mock_list = []
    expected_list = []
    ordered_list = sort_price_descending(mock_list)

    assert ordered_list == expected_list
  end

  test "Float add should add without floating point error" do
    value1 = 0.00000000000111
    value2 = 0.00000000000222
    expected_result = 0.00000000000333
    result = float_add(value1,value2)

    assert result == expected_result
  end

  test "Float add should handle add with integer value" do
    value1 = 1
    value2 = 0.000000000000001
    expected_result = 1.000000000000001
    result = float_add(value1,value2)

    assert result == expected_result
  end

  test "Float sub should subtract without floating point error" do
    value1 = 0.00000000000011
    value2 = 0.00000000000101
    expected_result = -0.00000000000090
    result = float_sub(value1,value2)

    assert result == expected_result
  end

  test "Float sub should handle subtract with integer value" do
    value1 = 1
    value2 = 0.000000000000001
    expected_result = 0.999999999999999
    result = float_sub(value1,value2)

    assert result == expected_result
  end
end
