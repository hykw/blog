defmodule Blog.Query do
  use Blog, :query

  @doc """
  Filter
  """
  @spec filter(queryable :: Ecto.Queryable.t(), args :: map) :: Ecto.Queryable.t()
  def filter(queryable, args) do
    Enum.reduce(args, queryable, fn
      {:order, order}, query ->
        order_with(query, order)

      {:filter, filter}, query ->
        filter_with(query, filter)

      _, query ->
        query
    end)
  end

  @spec order_with(queryable :: Ecto.Queryable.t(), order :: atom) :: Ecto.Queryable.t()
  defp order_with(queryable, order) do
    Enum.reduce(order, queryable, fn {field, sort_order}, query ->
      from q in query, order_by: [{^sort_order, ^field}]
    end)
  end

  @spec filter_with(queryable :: Ecto.Queryable.t(), filter :: list) :: Ecto.Queryable.t()
  defp filter_with(queryable, filter) do
    Enum.reduce(filter, queryable, fn
      {field, term}, query when is_boolean(term) or is_integer(term) ->
        from q in query, where: field(q, ^field) == ^term

      {field, term}, query when is_binary(term) ->
        from q in query, where: ilike(field(q, ^field), ^"%#{term}%")

      _, query ->
        query
    end)
  end
end
