defmodule ElixirExchangeTest do
  use ExUnit.Case
  doctest ElixirExchange

  test "greets the world" do
    assert ElixirExchange.hello() == :world
  end
end
