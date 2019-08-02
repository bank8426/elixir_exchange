defmodule ExchangeTest do
  use ExUnit.Case
  import ElixirExchange.Exchange

  doctest ElixirExchange.Exchange

  test "Partial exchange buy orders should buy at lowest price first" do
    orders = [
      %{"command"=> "sell", "price"=> 100.013, "amount"=> 3.0},
      %{"command"=> "sell", "price"=> 100.003, "amount"=> 3.0},
      %{"command"=> "buy", "price"=> 100.394, "amount"=> 5.0}
   ]
    expected_result = %{"buy" => [], "sell" => [%{"price" => 100.013, "volume" => 1.0}]}
    result = loop_orders(orders)
    assert result == expected_result
  end

  test "Partial exchange sell orders should sell at hightest price first" do
    orders = [
      %{"command"=> "buy", "price"=> 101.013, "amount"=> 3.0},
      %{"command"=> "buy", "price"=> 102.003, "amount"=> 3.0},
      %{"command"=> "sell", "price"=> 100.394, "amount"=> 5.0}
   ]
    expected_result = %{"buy" => [%{"price" => 101.013, "volume" => 1.0}], "sell" => []}
    result = loop_orders(orders)
    assert result == expected_result
  end

  test "When exchange same price, same amount should remove that matched record from list" do
    orders = [
         %{"command"=> "sell", "price"=> 100.000, "amount"=> 2.4},
         %{"command"=> "buy", "price"=> 100.000, "amount"=> 2.4}
      ]

    expected_result = %{"buy" => [], "sell" => []}
    result = loop_orders(orders)

    assert result == expected_result
  end

  test "When match same order type, same price and same amount should sum order amount together" do
    orders = [
         %{"command"=> "sell", "price"=> 100.000, "amount"=> 1.0},
         %{"command"=> "sell", "price"=> 100.000, "amount"=> 2.0}
      ]

    expected_result = %{"buy" => [], "sell" => [%{"price" => 100.0, "volume" => 3.0}]}
    result = loop_orders(orders)

    assert result == expected_result
  end

  test "Passing empty order list to loop_orders should return empty order book" do
    orders = []
    expected_result = %{"buy" => [], "sell" => []}
    result = loop_orders(orders)
    assert result == expected_result
  end
end
