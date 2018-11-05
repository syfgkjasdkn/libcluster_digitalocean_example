defmodule Example.MixProject do
  use Mix.Project

  def project do
    [
      app: :example,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Example.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster_digitalocean, "~> 0.1-rc"},
      {:distillery, "~> 2.0", runtime: false},
      {:elli_websocket, "~> 0.1"},
      {:elli, "~> 3.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
