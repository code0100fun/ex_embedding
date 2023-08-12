defmodule Embedding.Search do

  def search_wine(query) do
    embedding = Embedding.Model.predict(query)
    %{labels: labels} = Embedding.Index.search(embedding, 5)

    labels
    |> Nx.to_flat_list()
    |> get_wines()
  end

  def get_wines(ids) do
    ids
    |> Enum.map(fn id ->
      {:ok, record} = Embedding.Database.get(id)
      record
    end)
  end
end
