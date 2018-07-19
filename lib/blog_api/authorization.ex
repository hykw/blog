defimpl Blog.Authorization, for: Blog.User do
  alias Blog.{User, Post}

  @doc """
  Check authorization
  """
  @spec can?(subject :: Blog.User.t(), action :: atom, resource :: struct) :: :ok | {:error, any}
  def can?(subject, action, resource)

  @doc """
  User can read, update, and delete it self
  """
  def can?(%User{id: id}, action, %User{id: id})
      when action in [:read, :update, :delete],
      do: :ok

  @doc """
  User can read, update, and delete a Resource from the same Post
  """
  def can?(%User{id: user_id}, action, %Post{user_id: user_id})
      when action in [:read, :update, :delete],
      do: :ok

  @doc """
  Nothing matched
  """
  def can?(_, _, _), do: {:error, :unauthorized}
end
