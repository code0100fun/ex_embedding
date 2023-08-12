defmodule Embedding.Index do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts \\ []) do
    space = :l2
    dim = 384 # paraphrase-MiniLM-L6-v2 is 384 dimensional
    max_elements = 20000
    {:ok, index} = HNSWLib.Index.new(space, dim, max_elements, m: 32)
    {:ok, index}
  end

  def add(id, embedding) do
    GenServer.cast(__MODULE__, {:add, id, embedding})
  end

  @impl true
  def handle_cast({:add, ids, embeddings}, index) do
    :ok = HNSWLib.Index.add_items(index, embeddings, ids: ids)
    {:noreply, index}
  end

  def search(embedding, k) do
    GenServer.call(__MODULE__, {:search, embedding, k})
  end

  @impl true
  def handle_call({:search, embedding, k}, _from, index) do
    {:ok, labels, dists} = HNSWLib.Index.knn_query(index, embedding, k: k)
    {:reply, %{labels: labels, distances: dists}, index}
  end
end
