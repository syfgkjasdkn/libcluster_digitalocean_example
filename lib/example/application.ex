defmodule Example.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    topologies =
      Application.get_env(:libcluster, :topologies) || raise(ArgumentError, "need :topologies")

    port = Application.get_env(:example, :port) || raise(ArgumentError, "need :port")

    children = [
      {Registry, keys: :duplicate, name: Example.Registry},
      {Cluster.Supervisor, [topologies, [name: Example.Clusters.Supervisor]]},
      %{
        id: :elli,
        start: {:elli, :start_link, [[callback: Example.Handler, port: port]]}
      },
      {Task, fn -> Logger.info("Started elli on port: #{Example.port()}") end}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
