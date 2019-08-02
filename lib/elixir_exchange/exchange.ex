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
  def loop_orders(orders), do: loop_orders(orders, %{"buy"=> [] ,"sell"=> []})

  #Recursive case,
  #Seperate head and tail part of the order list
  #Put price and volume of head's order into order book map follow the order type.
  def loop_orders([head | tail], order_book) do
    #seperate command and order data
    order_type = head["command"]
    order = %{ "price" => head["price"] , "volume" => head["amount"]}

    order_book
    |>matching_order(order_type, order["price"])
    |>update_order_book(order_book, order_type, order)
    |>case do #then continue loop depend on partial order
      {:ok, order_book} -> loop_orders( tail , order_book)
      {:partial, order_book, partial_order} -> loop_orders( [partial_order | tail] , order_book)
    end
  end

  #Base case, will return order book when no orders left
  def loop_orders([] , order_book) ,do: order_book

  #Check is order match anything in order book
  #then, Return tuple indicate matching status
  #{:match_exchange, index} when found order in exchange match
  #{:match_same, index} when found same order type in current order book
  #{:nomatch} when not match with anything
  defp matching_order(order_book, order_type, target_price) do
    #find match price in opposite side
    found_exchange_index = order_book
                           |>get_opposite_order_list(order_type)
                           |>find_match_exchange_by_price(target_price,order_type)
    #find match price in same side
    found_same_order_index = order_book[order_type]
                             |> find_order_by_price(target_price)

    #return tuple of atom and index
    cond do
      found_exchange_index != nil -> {:match_exchange, found_exchange_index}
      found_same_order_index != nil -> {:match_same, found_same_order_index}
      true -> {:nomatch}
    end
  end

  #Update order book follow match result
  #If not found, concat order data to their own list
  defp update_order_book({:nomatch} ,order_book ,order_type ,new_order) do
    updated_list = order_book[order_type] ++ [new_order] |> sort_by_order_type(order_type)
    {:ok, Map.put(order_book, order_type, updated_list)}
  end
  #If found same, sum order amount with same price
  defp update_order_book({:match_same, index} ,order_book ,order_type ,new_order) do
    current_order_amount = get_order_volume_by_index(order_book[order_type], index)
    total_order_amount = float_add(current_order_amount, new_order["volume"])
    updated_list = List.replace_at(order_book[order_type], index, %{"price"=> new_order["price"] ,"volume"=> total_order_amount})
    {:ok, Map.put(order_book, order_type, updated_list)}
  end
  #If found exchange match, calculate new amount
  defp update_order_book({:match_exchange, index} ,order_book ,order_type ,new_order) do
    opposite_order_type = get_opposite_order_type(order_type)
    opposite_order_list = get_opposite_order_list(order_book, order_type)
    current_order_amount = get_order_volume_by_index(opposite_order_list, index)
    current_order_price = get_order_price_by_index(opposite_order_list, index)
    remaining_order_amount = float_sub(current_order_amount, new_order["volume"] )
    case remaining_order_amount do
      #remaining amount in order book, should update amount with the current price in order book
      value when value > 0 ->
        updated_list = List.replace_at(opposite_order_list, index, %{ "price"=> current_order_price ,"volume"=> value })
        {:ok, Map.put(order_book, opposite_order_type, updated_list)}
      #remaining amount in order,update new order book and return partial order
      value when value < 0 ->
        updated_list = List.delete_at(opposite_order_list, index)
        {:partial,
        Map.put(order_book, opposite_order_type, updated_list),
        %{"command"=> order_type, "price"=> new_order["price"], "amount"=> abs(value)}
      }
      #equal
      value when value == 0 ->
        updated_list = List.delete_at(opposite_order_list,index)
        {:ok, Map.put(order_book, opposite_order_type, updated_list)}
    end
  end

  #Return opposite order list
  defp get_opposite_order_list(order_book, order_type) do
    opposite_order_type = get_opposite_order_type(order_type)
    order_book[opposite_order_type]
  end

  #Return return volume of order from order list by index
  defp get_order_volume_by_index(list, index) do
    Enum.at(list,index)["volume"]
  end

  #Return return volume of order from order list by index
  defp get_order_price_by_index(list, index) do
    Enum.at(list,index)["price"]
  end

  #Return opposite order type from the input
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
