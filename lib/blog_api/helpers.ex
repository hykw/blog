defmodule BlogAPI.Helpers do
  @doc """
  Evaluates relations
  """
  defmacro can?(subject, {action, _, [resource]}) do
    quote do
      Blog.Authorization.can?(unquote(subject), unquote(action), unquote(resource))
    end
  end
end
