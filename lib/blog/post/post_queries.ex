defmodule Blog.Post.PostQueries do
  use Blog, :query

  alias Blog.Post

  @doc """
  Find post by handle
  """
  @spec post_by_handle(user_id :: binary, handle :: String.t()) :: Ecto.Queryable.t()
  def post_by_handle(user_id, handle) do
    from post in Post,
      where: post.user_id == ^user_id and post.handle == ^handle,
      limit: 1
  end

  @doc """
  Find post by user
  """
  @spec posts_by_user(user_id :: binary) :: Ecto.Queryable.t()
  def posts_by_user(user_id) do
    from post in Post,
      where: post.user_id == ^user_id,
      order_by: [asc: :inserted_at]
  end
end
