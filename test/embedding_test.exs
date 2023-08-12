defmodule EmbeddingTest do
  use ExUnit.Case
  doctest Embedding

  test "greets the world" do
    assert Embedding.hello() == :world
  end
end
