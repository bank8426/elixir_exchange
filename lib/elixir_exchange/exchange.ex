defmodule ElixirExchange.Exchange do
  import ElixirExchange.Helper, only: [sort_price_ascending: 1, sort_price_descending: 1]
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
    ElixirExchange.JSONReader.get_json(file)
    |>get_orders()
    |>loop_orders()
    |>ElixirExchange.JSONWriter.write_json_output()
  end

  #Return "orders" part of Maps
  defp get_orders(json) do
    json["orders"]
  end

  #Initial output with Map of "buy" and "sell"
  #Then loop throught all orders
  defp loop_orders(orders) do
    loop_orders(orders, %{"buy"=> [] ,"sell"=> []})
  end

  #Recursive case,
  #Seperate head and tail part of the order list
  #Put price and volume of head's order into output map follow the order type.
  defp loop_orders([head | tail], output) do
    #seperate command and order data
    {order_type, new_order} = Map.pop(head, "command")

    #check order match anything in order book
    match_result = matching(output, order_type, new_order["price"])

    #update output follow match result
    output = update_order_book(match_result, output, order_type, new_order)

    #continue loop
    loop_orders(tail , output)
  end

  #Base case, will return output when no orders left
  defp loop_orders([] , output) ,do: output

  #update order book
  #If not found, concat order data to their own list
  defp update_order_book({:nomatch} ,output ,order_type ,new_order) do
    Map.put(
      output,
      order_type,
      output[order_type] ++ [new_order] |> sort_by_order_type(order_type)
    )
  end
  #If found same, sum order amount with same price
  defp update_order_book({:match_same, index} ,output ,order_type ,new_order) do
    Map.put(
      output,
      order_type,
      List.replace_at(
        output[order_type],
        index,
        %{ "price"=> new_order["price"] ,"amount"=> Enum.at(output[order_type],index)["amount"] + new_order["amount"] }
      )
    )
  end
  #If found exchange match, calculate new amount
  defp update_order_book({:match_exchange, index} ,output ,order_type ,new_order) do
    opposite_order_type = get_opposite_order_type(order_type)
    case Enum.at(output[opposite_order_type],index)["amount"] - new_order["amount"] do
      #remaining amount in order book
      value when value > 0 -> Map.put(
        output,
        opposite_order_type,
        List.replace_at(
          output[opposite_order_type],
          index,
          %{ "price"=> new_order["price"] ,"amount"=> value }
        )
      )
      #remaining amount in order, put remaining amount to order book
      value when value < 0 -> Map.put(
        output,
        order_type,
        output[order_type] ++ [%{ "price"=> new_order["price"] ,"amount"=> abs(value) }] |> sort_by_order_type(order_type)
      )
      #equal
      value when value == 0 -> Map.put(
        output,
        opposite_order_type,
        List.delete_at(
          output[opposite_order_type],
          index
        )
      )
    end
  end

  #Return tuple indicate matching status
  #{:match_exchange, index} when found order in exchange match
  #{:match_same, index} when found same order type in current order book
  #{:nomatch} when not match with anything
  defp matching(output, order_type, target_price) do
    opposite_order_type = get_opposite_order_type(order_type)
    #find match price in opposite site
    found_exchange_index = find_order_by_price(output[opposite_order_type], target_price)
    found_same_order_index = find_order_by_price(output[order_type], target_price)

    #find exchange match
    cond do
      found_exchange_index != nil -> {:match_exchange, found_exchange_index}
      found_same_order_index != nil -> {:match_same, found_same_order_index}
      true -> {:nomatch}
    end
  end

  #return opposite order type from the input
  defp get_opposite_order_type("buy"), do: "sell"
  defp get_opposite_order_type("sell"), do: "buy"

  #Return index of order in list with the same price
  defp find_order_by_price(list, target_price) do
    Enum.find_index(list, &(&1["price"] == target_price))
  end

  #Return sorted list by price base on order type,
  #For "buy" will sort descending
  #For "sell" will sort ascending
  defp sort_by_order_type(order_list, "buy"), do: sort_price_descending(order_list)
  defp sort_by_order_type(order_list, "sell"), do: sort_price_ascending(order_list)
end
