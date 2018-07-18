defmodule Blog.User.UserQueries do
  use Blog, :query

  alias Blog.User

  @doc """
  Find an active User by email
  """
  @spec user_by_email(email :: String.t()) :: Ecto.Queryable.t()
  def user_by_email(email) do
    email = String.downcase(email)

    from user in User,
      where: user.email == ^email,
      limit: 1
  end

  @doc """
  Filter queryable by active state
  """
  @spec filter_active(queryable :: Ecto.Queryable.t(), active :: boolean) :: Ecto.Queryable.t()
  def filter_active(queryable, active) do
    from user in queryable,
      where: user.active == ^active
  end
end
