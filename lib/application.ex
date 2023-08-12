defmodule Embedding.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Nx.Serving,
        serving: Embedding.Model.serving(),
        name: Embedding.Model,
        batch_size: 8,
        batch_timeout: 100},
      Embedding.Index,
      Embedding.Database
    ]

    opts = [strategy: :one_for_one, name: Embedding.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
