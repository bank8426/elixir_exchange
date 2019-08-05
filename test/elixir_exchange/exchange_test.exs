defmodule ExchangeTest do
  use ExUnit.Case
  import ElixirExchange.Exchange

  doctest ElixirExchange.Exchange

  describe "When loop throught orders list" do
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

  describe "When matching exchange buy order" do
    test "Should return lowest matched price even target higher price" do
      sell_sorted_list = [
        %{"price" => 100.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 102.0, "volume" => 3.0},
      ]
      target_buy_price = 102.0
      order_type = "buy"
      result = find_match_exchange_by_price(sell_sorted_list, target_buy_price, order_type)
      expected_result = 0

      assert result == expected_result
    end

    test "Should return lowest matched price in target price range" do
      sell_sorted_list = [
        %{"price" => 100.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 102.0, "volume" => 3.0},
      ]
      target_buy_price = 100.0
      order_type = "buy"
      result = find_match_exchange_by_price(sell_sorted_list, target_buy_price, order_type)
      expected_result = 0

      assert result == expected_result
    end

    test "Should return nil when not match" do
      sell_sorted_list = [
        %{"price" => 100.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 102.0, "volume" => 3.0},
      ]
      target_buy_price = 99.0
      order_type = "buy"
      result = find_match_exchange_by_price(sell_sorted_list, target_buy_price, order_type)
      expected_result = nil

      assert result == expected_result
    end
  end

  describe "When matching exchange sell order" do
    test "Should return highest matched price even target lower price" do
      buy_sorted_list = [
        %{"price" => 102.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 100.0, "volume" => 3.0},
      ]
      target_sell_price = 100.0
      order_type = "sell"
      result = find_match_exchange_by_price(buy_sorted_list, target_sell_price, order_type)
      expected_result = 0

      assert result == expected_result
    end

    test "Should return highest matched price in target price range" do
      buy_sorted_list = [
        %{"price" => 102.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 100.0, "volume" => 3.0},
      ]
      target_sell_price = 102.0
      order_type = "sell"
      result = find_match_exchange_by_price(buy_sorted_list, target_sell_price, order_type)
      expected_result = 0

      assert result == expected_result
    end

    test "Should return nil when not match" do
      buy_sorted_list = [
        %{"price" => 102.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 100.0, "volume" => 3.0},
      ]
      target_sell_price = 103.0
      order_type = "sell"
      result = find_match_exchange_by_price(buy_sorted_list, target_sell_price, order_type)
      expected_result = nil

      assert result == expected_result
    end
  end

  describe "When matching same order" do
    test "Should return same matched price" do
      list = [
        %{"price" => 102.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 100.0, "volume" => 3.0},
      ]
      target_price = 101.0
      result = find_order_by_price(list, target_price)
      expected_result = 1

      assert result == expected_result
    end

    test "Should return nil when not match" do
      list = [
        %{"price" => 102.0, "volume" => 3.0},
        %{"price" => 101.0, "volume" => 3.0},
        %{"price" => 100.0, "volume" => 3.0},
      ]
      target_price = 103.0
      result = find_order_by_price(list, target_price)
      expected_result = nil

      assert result == expected_result
    end
  end
end
