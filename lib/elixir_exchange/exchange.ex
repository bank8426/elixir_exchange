defmodule ElixirExchange.Exchange do
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

  #This function will return "orders" part of Maps
  defp get_orders(json) do
    json["orders"]
  end

  #This function will initial output with Map of "buy" and "sell"
  #Then loop throught all orders
  defp calculate(orders) do
    loop_orders(orders, %{ buy: [] , sell: []})
  end

  #This function is recursive case,
  #Seperate head and tail part of the order list
  #Put price and volume of head's order into output map follow the order type.
  defp loop_orders([head | tail] , output) do
    output = case head["command"] do
      "buy" -> Map.put(output, :buy, output[:buy] ++ [ %{ price: head["price"] , volume: head["amount"] }])
      "sell" -> Map.put(output, :sell, output[:sell] ++ [ %{ price: head["price"] , volume: head["amount"] }])
    end
    loop_orders(tail , output)
  end

  #This function is base case, will return output when no orders left
  defp loop_orders([] , output) ,do: output
end
