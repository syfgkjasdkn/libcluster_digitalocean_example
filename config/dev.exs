use Mix.Config

config :example, port: 0

config :libcluster,
  debug: true,
  topologies: [
    example: [
      strategy: Cluster.Strategy.Gossip,
      connect: {Example, :connect, []},
      disconnect: {Example, :disconnect, []}
    ]
  ]
