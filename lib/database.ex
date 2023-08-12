defmodule Embedding.Database do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts \\ []) do
    {:ok, {1, %{}}}
  end

  def create(%{embedding: _embedding } = data) do
    GenServer.call(__MODULE__, {:create, data})
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @impl true
  def handle_call({:create, data}, _from, {next_id, db}) do
    str_id = Integer.to_string(next_id)
    record = Map.merge(data, %{id: next_id})
    db = Map.put(db, str_id, record)
    {:reply, {:ok, record}, {next_id + 1, db}}
  end

  @impl true
  def handle_call({:get, id}, _from, {next_id, db}) do
    record = Map.get(db, Integer.to_string(id))
    {:reply, {:ok, record}, {next_id, db}}
  end
end
