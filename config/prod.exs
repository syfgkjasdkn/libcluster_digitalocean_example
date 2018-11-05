use Mix.Config

token = System.get_env("DIGITALOCEAN_TOKEN") || raise("need DIGITALOCEAN_TOKEN env var to be set")

config :example, port: 80

config :libcluster,
  topologies: [
    example: [
      strategy: ClusterDigitalOcean.TagStrategy,
      connect: {Example, :connect, []},
      disconnect: {Example, :disconnect, []},
      config: [
        node_basename: "example",
        tag_name: "awesome",
        token: token,
        polling_interval: 10_000
      ]
    ]
  ]
