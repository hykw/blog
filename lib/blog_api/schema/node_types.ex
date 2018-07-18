defmodule BlogAPI.Schema.NodeTypes do
  use BlogAPI, :type

  @resources [
    user: Blog.User,
    post: Blog.Post
  ]

  node interface do
    resolve_type &node_type/2
  end

  object :node_queries do
    node field do
      resolve &node_by_id/2
    end
  end

  for {type, schema} <- @resources do
    def node_by_id(%{type: unquote(type), id: id}, %{context: %{user: user}}) do
      with {:ok, struct} <- Repo.find(unquote(schema), id),
           :ok <- can?(user, read(struct)) do
        {:ok, struct}
      end
    end

    def node_type(%{__struct__: unquote(schema)}, _) do
      unquote(type)
    end
  end

  def node_by_id(_, _) do
    {:error, "Unknown node"}
  end

  def node_type(_, _) do
    {:error, "Unknown type"}
  end
end
