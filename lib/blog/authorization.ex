defprotocol Blog.Authorization do
  @doc """
  Evaluates relations
  """
  def can?(subject, action, resource)
end
