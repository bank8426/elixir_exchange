defmodule ElixirExchange.JSONWriter do

  @doc """
  This function will take output map,
  then parse to JSON string and write down to output.json
  iex> data = %{
  ...>buy: [%{"price" => 90.394, "volume" => 3.445}],
  ...>sell: [%{"price" => 100.003, "volume" => 2.4}]
  ...>}
  iex>ElixirExchange.JSONWriter.write_json_output(data)
  :ok
  """
  def write_json_output(output) do
    File.write("output.json",Jason.encode!(output,[pretty: true]), [:binary])
  end
end
