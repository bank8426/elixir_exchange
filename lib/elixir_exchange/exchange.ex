defmodule ElixirExchange.Exchange do
  import ElixirExchange.Helper, only: [sort_price_ascending: 1, sort_price_descending: 1, float_add: 2, float_sub: 2]
  import ElixirExchange.JSONReader, only: [get_json: 1]
  import ElixirExchange.JSONWriter, only: [write_json_output: 1]

  @moduledoc """
  Provides a function `exchange/1` to read input file and calculate order book results
  """

  @doc """
  read input file and calculate order book results,
  then write to output file
  ## Parameters
    - file: String that represents the path to json file.
  ## Examples
    iex> ElixirExchange.Exchange.exchange("priv/input_1.json")
    :ok
  """
  def exchange(file) do
    file
    |>get_json()
    |>get_orders()
    |>loop_orders()
    |>write_json_output()
  end

  #Return "orders" part of Maps
  defp get_orders(json), do: json["orders"]

  #Initial order book with Map of "buy" and "sell"
  #Then loop throught all orders
  defp loop_orders(orders), do: loop_orders(orders, %{"buy"=> [] ,"sell"=> []})

  #Recursive case,
  #Seperate head and tail part of the order list
  #Put price and volume of head's order into order book map follow the order type.
  defp loop_orders([head | tail], order_book) do
    #seperate command and order data
    {order_type, new_order} = Map.pop(head, "command")
    new_order = %{ "price" => new_order["price"] , "volume" => new_order["amount"]}

    order_book
    #check order match anything in order book
    |>matching_order(order_type, new_order["price"])
    #update order book follow match result
    |>update_order_book(order_book, order_type, new_order)
    #then continue loop
    |>case do
      {:ok, order_book} -> loop_orders( tail , order_book)
      {:partial, order_book, partial_order} -> loop_orders( [partial_order | tail] , order_book)
    end
  end

  #Base case, will return order book when no orders left
  defp loop_orders([] , order_book) ,do: order_book

  #Return tuple indicate matching status
  #{:match_exchange, index} when found order in exchange match
  #{:match_same, index} when found same order type in current order book
  #{:nomatch} when not match with anything
  defp matching_order(order_book, order_type, target_price) do
    #find match price in opposite side
    found_exchange_index = get_opposite_order_list(order_book, order_type) |> find_match_exchange_by_price(target_price,order_type)
    #find match price in same side
    found_same_order_index = find_order_by_price(order_book[order_type], target_price)

    #return tuple of atom and index
    cond do
      found_exchange_index != nil -> {:match_exchange, found_exchange_index}
      found_same_order_index != nil -> {:match_same, found_same_order_index}
      true -> {:nomatch}
    end
  end

  #update order book
  #If not found, concat order data to their own list
  defp update_order_book({:nomatch} ,order_book ,order_type ,new_order) do
    updated_list = order_book[order_type] ++ [new_order] |> sort_by_order_type(order_type)
    {:ok, Map.put(order_book, order_type, updated_list)}
  end
  #If found same, sum order amount with same price
  defp update_order_book({:match_same, index} ,order_book ,order_type ,new_order) do
    current_order_amount = Enum.at(order_book[order_type],index)["volume"]
    total_order_amount = float_add(current_order_amount, new_order["volume"])
    updated_list = List.replace_at(order_book[order_type], index, %{"price"=> new_order["price"] ,"volume"=> total_order_amount})
    {:ok, Map.put(order_book, order_type, updated_list)}
  end
  #If found exchange match, calculate new amount
  defp update_order_book({:match_exchange, index} ,order_book ,order_type ,new_order) do
    opposite_order_type = get_opposite_order_type(order_type)
    current_order = Enum.at(order_book[opposite_order_type],index)
    remaining_order_amount = float_sub(current_order["volume"], new_order["volume"] )
    case remaining_order_amount do
      #remaining amount in order book
      value when value > 0 ->
        updated_list = List.replace_at(order_book[opposite_order_type], index, %{ "price"=> new_order["price"] ,"volume"=> value })
        {:ok, Map.put(order_book, opposite_order_type, updated_list)}
      #remaining amount in order,update new order book and return partial order
      value when value < 0 ->
        updated_list = List.delete_at(order_book[opposite_order_type], index)
        {:partial,
        Map.put(order_book, opposite_order_type, updated_list),
        %{"command"=> order_type, "price"=> new_order["price"], "amount"=> abs(value)}
      }
      #equal
      value when value == 0 ->
        updated_list = List.delete_at(order_book[opposite_order_type],index)
        {:ok, Map.put(order_book, opposite_order_type, updated_list)}
    end
  end

  defp get_opposite_order_list(order_book, order_type) do
    opposite_order_type = get_opposite_order_type(order_type)
    order_book[opposite_order_type]
  end

  #return opposite order type from the input
  defp get_opposite_order_type("buy"), do: "sell"
  defp get_opposite_order_type("sell"), do: "buy"

  #Return index of order in list with the same price
  defp find_order_by_price(list, target_price) do
    Enum.find_index(list, &(&1["price"] == target_price))
  end
  #Return lowest price match order
  defp find_match_exchange_by_price(list, target_price, "buy") do
    Enum.find_index(list, &(&1["price"] <= target_price))
  end
  #Return highest price match order
  defp find_match_exchange_by_price(list, target_price, "sell") do
    Enum.find_index(list, &(&1["price"] >= target_price))
  end

  #Return sorted list by price base on order type,
  #For "buy" will sort descending
  #For "sell" will sort ascending
  defp sort_by_order_type(order_list, "buy"), do: sort_price_descending(order_list)
  defp sort_by_order_type(order_list, "sell"), do: sort_price_ascending(order_list)
end
