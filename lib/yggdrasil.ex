defmodule Yggdrasil do
  use Application

  alias Yggdrasil.Channel

  @backend YProcess.Backend.PG2
  @generator Yggdrasil.Publisher.Generator
  @broker Yggdrasil.Broker

  @doc """
  Subscribes to a `channel`.
  """
  def subscribe(channel) do
    Yggdrasil.Backend.join(channel, self())
  end

  @doc """
  Unsubscribe from a `channel`.
  """
  def unsubscribe(channel) do
    Yggdrasil.Backend.leave(channel, self())
  end

  @doc """
  Emits a `message` in a `channel`. Bypasses the adapter.
  """
  def publish(%Channel{channel: channel, decoder: decoder}, message) do
    registry = apply(@generator, :get_registry, [])
    publisher = {:via, registry, {Yggdrasil.Publisher, channel, decoder}}
    Yggdrasil.Publisher.sync_notify(publisher, channel, message)
  end
  def publish(channel, message) do
    Yggdrasil.Backend.emit(channel, message)
  end

  ##
  # Monitors table.
  defp get_monitors_table do
    :ets.new(:monitors, [:set, :public, write_concurrency: false,
                         read_concurrency: true])
  end

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    monitors = get_monitors_table()

    children = [
      supervisor(@generator, [[name: @generator]]),
      worker(@broker, [@generator, monitors, [name: @broker]])
    ] 

    children = case Application.get_env(:y_process, :backend, @backend) do
      YProcess.Backend.PG2 -> children
      YProcess.Backend.PhoenixPubSub ->
        [supervisor(YProcess.PhoenixPubSub, []) | children]
    end

    opts = [strategy: :rest_for_one, name: Yggdrasil.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
