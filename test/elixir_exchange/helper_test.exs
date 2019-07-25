defmodule HelperTest do
  use ExUnit.Case
  import ElixirExchange.Helper

  doctest ElixirExchange.Helper

  test "Passing list should sort ascending by price" do
    mock_list = [
      %{price: 90.394, volume: 3.445},
      %{price: 89.394, volume: 4.3},
      %{price: 90.15, volume: 1.305}
    ]
    expected_list = [
      %{price: 89.394, volume: 4.3},
      %{price: 90.15, volume: 1.305},
      %{price: 90.394, volume: 3.445}
    ]
    ordered_list = sort_price_ascending(mock_list)
    assert ordered_list == expected_list
  end

  test "Passing list should sort descending by price" do
    mock_list = [
      %{price: 90.394, volume: 3.445},
      %{price: 89.394, volume: 4.3},
      %{price: 90.15, volume: 1.305}
    ]
    expected_list = [
      %{price: 90.394, volume: 3.445},
      %{price: 90.15, volume: 1.305},
      %{price: 89.394, volume: 4.3}
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
end
