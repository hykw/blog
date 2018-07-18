defmodule BlogAPI.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Absinthe.Relay.Node.ParseIDs
  alias BlogAPI.{HandleToken, HandleErrors}

  @unprotected_types [
    :register_user_payload
  ]

  @node_id_rules [
    user_id: :user,
    post_id: :post
  ]

  import_types BlogAPI.Schema.NodeTypes
  import_types BlogAPI.Schema.UserTypes

  query do
    import_fields :node_queries
    import_fields :user_queries
  end

  mutation do
    import_fields :user_mutations
  end

  @doc """
  Context
  """
  def context(context) do
    Map.put(context, :loader, Blog.Dataloader.new())
  end

  @doc """
  Plugins
  """
  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  @doc """
  Middleware for unprotected queries and mutations
  """
  def middleware(middleware, %{type: type}, %{identifier: identifier})
      when identifier in [:query, :mutation] and type in @unprotected_types do
    [{ParseIDs, @node_id_rules}] ++ middleware ++ [HandleErrors]
  end

  @doc """
  Middleware for protected queries and mutations
  """
  def middleware(middleware, _field, %{identifier: identifier})
      when identifier in [:query, :mutation] do
    [HandleToken, {ParseIDs, @node_id_rules}] ++ middleware ++ [HandleErrors]
  end

  @doc """
  Default Middleware
  """
  def middleware(middleware, _field, _object) do
    middleware
  end
end
