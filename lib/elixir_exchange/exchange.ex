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
    |>calculate()
    |>ElixirExchange.JSONWriter.write_json_output()
  end

  #Return "orders" part of Maps
  defp get_orders(json) do
    json["orders"]
  end

  #Initial output with Map of "buy" and "sell"
  #Then loop throught all orders
  defp calculate(orders) do
    loop_orders(orders, %{"buy"=> [] ,"sell"=> []})
  end

  #Recursive case,
  #Seperate head and tail part of the order list
  #Put price and volume of head's order into output map follow the order type.
  defp loop_orders([head | tail], output) do
    #seperate command and order data
    {order_type, new_order} = Map.pop(head, "command")
    #concat order data to their own list
    new_order_list = output[order_type] ++ [new_order] |> sort_by_order_type(order_type)
    #update output
    output = Map.put(output, order_type, new_order_list)
    #continue loop
    loop_orders(tail , output)
  end
  #Base case, will return output when no orders left
  defp loop_orders([] , output) ,do: output

  #Return sorted list by price base on order type,
  #For "buy" will sort descending
  #For "sell" will sort ascending
  defp sort_by_order_type(order_list, "buy"), do: sort_price_descending(order_list)
  defp sort_by_order_type(order_list, "sell"), do: sort_price_ascending(order_list)
end
