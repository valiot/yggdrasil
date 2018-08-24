defmodule Yggdrasil.Settings do
  @moduledoc """
  This module defines the available settings for Yggdrasil.
  """
  use Skogsra

  #########
  # Helpers

  @doc false
  def gen_env_name(namespace, key, default \\ "_YGGDRASIL_") do
    prefix =
      namespace
      |> Atom.to_string()
      |> String.trim("Elixir.")
      |> String.upcase()
      |> String.split(".")
      |> Enum.join("_")
    name = key |> Atom.to_string() |> String.upcase()
    prefix <> default <> name
  end

  ############################
  # Yggdrasil process registry

  @doc """
  Process registry.

  ```
  config :yggdrasil,
    registry: ExReg
  ```
  """
  app_env :yggdrasil_process_registry, :yggdrasil, :process_registry,
    default: ExReg

  ############################
  # Yggdrasil registry options

  @doc """
  Module registry table name.

  ```
  config :yggdrasil,
    module_registry: :yggdrasil_registry
  ```
  """
  app_env :yggdrasil_module_registry, :yggdrasil, :module_registry,
    default: :yggdrasil_registry

  ################################
  # Yggdrasil distribution options

  @doc """
  Pub-sub adapter to use for channels. Default value is `Phoenix.PubSub.PG2`.

  ```
  config :yggdrasil,
    pubsub_adapter: Phoenix.PubSub.PG2
  ```
  """
  app_env :yggdrasil_pubsub_adapter, :yggdrasil, :pubsub_adapter,
    default: Phoenix.PubSub.PG2

  @doc """
  Pub-sub name. By default is `Yggdrasil.PubSub`.

  ```
  config :yggdrasil,
    pubsub_name: Yggdrasil.PubSub
  ```
  """
  app_env :yggdrasil_pubsub_name, :yggdrasil, :pubsub_name,
    default: Yggdrasil.PubSub

  @doc """
  Pub-sub options. By default are `[pool_size: 1]`.

  ```
  config :yggdrasil,
    pubsub_options: [pool_size: 1]
  ```
  """
  app_env :yggdrasil_pubsub_options, :yggdrasil, :pubsub_options,
    default: [pool_size: 1]

  #############################
  # Yggdrasil publisher options

  @doc """
  Yggdrasil publisher options. This options are for `:poolboy`. Defaults to
  `[size: 5, max_overflow: 10]`.

  ```
  config :yggdrasil,
    publisher_options: [size: 5, max_overflow: 10]
  ```
  """
  app_env :yggdrasil_publisher_options, :yggdrasil, :publisher_options,
    default: [size: 5, max_overflow: 10]
end
