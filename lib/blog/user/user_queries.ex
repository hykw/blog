defmodule Blog.User.UserQueries do
  use Blog, :query

  alias Blog.Post

  @doc """
  Find Posts by User
  """
  @spec posts_by_user(user_id :: binary) :: Ecto.Queryable.t()
  def posts_by_user(user_id) do
    from post in Post,
      where: post.user_id == ^user_id,
      order_by: [asc: :inserted_at]
  end
end
