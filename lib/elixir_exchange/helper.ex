defmodule ElixirExchange.Helper do
  @moduledoc """
  Provides a function `sort_price_ascending/1` to sort list by price with ascending order
  Provides a function `sort_price_descending/1` to sort list by price with descending order
  """

  @doc """
  sort list by price from low to high
  ## Parameters
    - list: list of unsorted orders
  ## Examples
    iex> data = [
    ...>%{price: 90.394, volume: 3.445},
    ...>%{price: 89.394, volume: 4.3},
    ...>%{price: 90.15, volume: 1.305}
    ...>]
    iex>ElixirExchange.Helper.sort_price_ascending(data)
    [
      %{price: 89.394, volume: 4.3},
      %{price: 90.15, volume: 1.305},
      %{price: 90.394, volume: 3.445}
    ]
  """
  def sort_price_ascending(list) do
    list
    |>Enum.sort_by(&(price(&1)))
  end

  @doc """
  sort list by price from high to low
  ## Parameters
    - list: list of unsorted orders
  ## Examples
    iex> data = [
    ...> %{price: 90.394, volume: 3.445},
    ...> %{price: 89.394, volume: 4.3},
    ...> %{price: 90.15, volume: 1.305}
    ...> ]
    iex>ElixirExchange.Helper.sort_price_descending(data)
    [
      %{price: 90.394, volume: 3.445},
      %{price: 90.15, volume: 1.305},
      %{price: 89.394, volume: 4.3}
    ]
  """
  def sort_price_descending(list) do
    list
    |>Enum.sort_by(&(-price(&1)))
  end

  #get price from order
  defp price(order) do
    order["price"]
  end
end
