defmodule SlimPickensTest do
  use ExUnit.Case
  doctest SlimPickens

  test "greets the world" do
    assert SlimPickens.hello() == :world
  end
end
