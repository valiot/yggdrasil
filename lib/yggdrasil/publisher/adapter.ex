defmodule Yggdrasil.Publisher.Adapter do
  @moduledoc """
  Publisher adapter behaviour.
  """
  alias Yggdrasil.Channel
  alias Yggdrasil.Registry, as: Reg

  @doc """
  Callback to start a publisher with a `namespace` and some `GenServer`
  `options`.
  """
  @callback start_link(
    namespace :: atom(),
    options :: GenServer.options()
  ) :: GenServer.on_start()

  @doc """
  Publishes a `message` in a `channel` using a `publisher` and optional and
  unused `options`.
  """
  @callback publish(GenServer.server(), Channel.t(), term()) ::
    :ok | {:error, term()}
  @callback publish(GenServer.server(), Channel.t(), term(), Keyword.t()) ::
    :ok | {:error, term()}

  @doc """
  Use to implement `Yggdrasil.Publisher.Adapter` behaviour.
  """
  defmacro __using__(_) do
    quote do
      @behaviour Yggdrasil.Publisher.Adapter

      @doc false
      def start_link(namespace, options \\ [])

      def start_link(namespace, options) do
        GenServer.start_link(__MODULE__, namespace, options)
      end

      @doc false
      def publish(publisher, channel, message, options \\ [])

      def publish(publisher, %Channel{} = channel, message, _options) do
        GenServer.call(publisher, {:publish, channel, message})
      end

      defoverridable [
        start_link: 1,
        start_link: 2,
        publish: 3,
        publish: 4
      ]
    end
  end

  @doc """
  Generic publisher adapter starter that receives a `channel` and an optional
  `GenServer` options.
  """
  @spec start_link(Channel.t()) :: GenServer.on_start()
  @spec start_link(
    Channel.t(),
    GenServer.options()
  ) :: GenServer.on_start()
  def start_link(channel, options \\ [])

  def start_link(
    %Channel{
      adapter: adapter,
      namespace: namespace
    },
    options
  ) do
    with {:ok, module} <- Reg.get_publisher_module(adapter) do
      module.start_link(namespace, options)
    end
  end

  @doc """
  Generic publisher adapter publish function. Publisher a `message` in a
  `channel` using a `publisher` and some `options`.
  """
  def publish(
    publisher,
    %Channel{adapter: adapter} = channel,
    message,
    options
  ) do
    with {:ok, module} <- Reg.get_publisher_module(adapter) do
      module.publish(publisher, channel, message, options)
    end
  end

  @doc """
  Generic publisher adapter stopper that receives the `pid`.
  """
  @spec stop(GenServer.name()) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end
end
