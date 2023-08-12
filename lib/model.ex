defmodule Embedding.Model do

  @batch_size 10
  @sequence_length 1000
  @model_name "sentence-transformers/paraphrase-MiniLM-L6-v2"

  def predict(text) do
    Nx.Serving.batched_run(Embedding.Model, text)
  end

  def serving() do
    {:ok, %{model: model, params: params}} = Bumblebee.load_model({:hf, @model_name})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, @model_name})

    {_init_fn, predict_fn} = Axon.build(model, compiler: EXLA)

    Nx.Serving.new(fn _opts ->
      fn %{size: size} = inputs ->
        inputs = Nx.Batch.pad(inputs, @batch_size - size)
        predict_fn.(params, inputs)[:pooled_state]
      end
    end)
    |> Nx.Serving.client_preprocessing(fn input ->
      inputs = Bumblebee.apply_tokenizer(tokenizer, input,
        length: @sequence_length,
        return_token_type_ids: false
      )

      {Nx.Batch.concatenate([inputs]), :ok}
    end)
  end
end
