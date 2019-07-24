defmodule ElixirExchange.JSONReader do

  @doc """
  This function will take path to a JSON file and parse string to JSON
  iex> ElixirExchange.JSONReader.get_json("priv/input_1.json")
  {:ok,
   %{
   "orders" => [
     %{"amount" => 2.4, "command" => "sell", "price" => 100.003},
     %{"amount" => 3.445, "command" => "buy", "price" => 90.394}
   ]
  }}
  """
  def get_json(path) do
    with {:ok, body} <- File.read(path),
         {:ok, json} <- Poison.decode(body)
    do
      {:ok, json}
    else
      err -> err
    end
  end
end
