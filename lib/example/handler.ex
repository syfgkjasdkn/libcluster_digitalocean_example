defmodule Example.Handler do
  @moduledoc false
  @behaviour :elli_handler
  @behaviour :elli_websocket_handler

  require EEx
  EEx.function_from_file(:def, :index_html, "lib/example/index.html.eex", [])

  @impl :elli_handler
  def init(req, args) do
    case :elli_request.get_header("Upgrade", req) do
      "websocket" -> init_ws(:elli_request.path(req), req, args)
      _ -> :ignore
    end
  end

  defp init_ws(["nodes"], _req, _args) do
    {:ok, :handover}
  end

  defp init_ws(_, _, _) do
    :ignore
  end

  @impl :elli_handler
  def handle(req, args) do
    method =
      case :elli_request.get_header("Upgrade", req) do
        "websocket" -> :websocket
        _ -> :elli_request.method(req)
      end

    handle(method, :elli_request.path(req), req, args)
  end

  defp handle(:websocket, ["nodes"], req, _args) do
    :elli_websocket.upgrade(req, handler: __MODULE__)
    {:close, ""}
  end

  defp handle(:GET, [], _req, _args) do
    {200, [], index_html()}
  end

  defp handle(_, _, _, _) do
    {404, [], "page not found"}
  end

  @impl :elli_handler
  def handle_event(_event, _data, _args) do
    :ok
  end

  @impl :elli_websocket_handler
  def websocket_init(_req, _opts) do
    {:ok, _} = Registry.register(Example.Registry, :cluster_change, [])
    {:ok, [], []}
  end

  @impl :elli_websocket_handler
  def websocket_handle(_req, {:text, "list"}, state) do
    reply = build_reply!("list", %{"nodes" => Node.list()})
    {:reply, {:text, reply}, state}
  end

  def websocket_handle(_req, _frame, state) do
    {:ok, state}
  end

  @impl :elli_websocket_handler
  def websocket_info(_req, {:connect, node}, state) do
    reply = build_reply!("connected", %{"node" => node})
    {:reply, {:text, reply}, state}
  end

  def websocket_info(_req, {:disconnect, node}, state) do
    reply = build_reply!("disconnected", %{"node" => node})
    {:reply, {:text, reply}, state}
  end

  def websocket_info(_req, _message, state) do
    {:ok, state}
  end

  @impl :elli_websocket_handler
  def websocket_handle_event(_name, _data, _state) do
    :ok
  end

  defp build_reply!(type, payload) do
    Jason.encode_to_iodata!(%{"type" => type, "payload" => payload})
  end
end
