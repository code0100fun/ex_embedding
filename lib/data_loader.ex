defmodule Embedding.DataLoader do

  def load() do
    "priv/wine_documents.jsonl"
    |> File.stream!()
    |> Enum.take(200)
    |> Stream.map(&Jason.decode!/1)
    |> Stream.map(fn document ->
      desc = Embedding.DataLoader.format_document(document)
      embedding = Embedding.Model.predict(desc)
      # {document["name"], document["url"], desc, embedding}
      {document, embedding}
    end)
    |> Stream.with_index()
    |> Enum.each(fn {{document, embedding}, i} ->
      {:ok, record} = Embedding.Database.create(%{
        document: document,
        embedding: embedding
      })
      id = Nx.tensor([record[:id]])
      Embedding.Index.add(id, embedding)
      # dbg(%{record: record})
      # IO.write(".")
      if rem(i, 20) == 0 do
        IO.write(".")
      end
      if rem(i, 1000) == 0 do
        IO.write("\n")
      end
    end)
    # IO.write("\n")
  end

  def format_document(document) do
    "Name: #{document["name"]}\n" <>
      "Varietal: #{document["varietal"]}\n" <>
      "Location: #{document["location"]}\n" <>
      "Alcohol Volume: #{document["alcohol_volume"]}\n" <>
      "Alcohol Percent: #{document["alcohol_percent"]}\n" <>
      "Price: #{document["price"]}\n" <>
      "Winemaker Notes: #{document["notes"]}\n" <>
      "Reviews:\n#{format_reviews(document["reviews"])}"
  end

  defp format_reviews(reviews) do
    reviews
    |> Enum.map(fn review ->
      "Reviewer: #{review["author"]}\n" <>
        "Review: #{review["review"]}\n" <>
        "Rating: #{review["rating"]}"
    end)
    |> Enum.join("\n")
  end
end
