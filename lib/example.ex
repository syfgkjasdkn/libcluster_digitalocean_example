defmodule Example do
  @moduledoc false

  @doc false
  def connect(node) do
    connected? = :net_kernel.connect_node(node)

    # if connected? do
    :ok = publish_cluster_change(:connect, node)
    # end

    connected?
  end

  @doc false
  def disconnect(node) do
    disconnected? = :net_kernel.disconnect(node)

    # if disconnected? do
    :ok = publish_cluster_change(:disconnect, node)
    # end

    disconnected?
  end

  # TODO this is a hack
  @doc false
  def port do
    elli =
      Example.Application.Supervisor
      |> Supervisor.which_children()
      |> Enum.find_value(fn
        {:elli, pid, _, _} -> pid
        _other -> nil
      end) || raise("can't find :elli in the root supervisor")

    {:state, {:plain, socket}, _tab, _port, _opts, _handler} = :sys.get_state(elli)
    {:ok, port} = :inet.port(socket)

    port
  end

  defp publish_cluster_change(change, node) do
    message = {change, node}

    Registry.dispatch(Example.Registry, :cluster_change, fn entries ->
      Enum.each(entries, fn {pid, _} -> send(pid, message) end)
    end)
  end
end
