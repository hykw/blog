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
end
