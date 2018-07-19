defmodule Blog.User.ActivateUser do
  use Blog, :command

  alias Blog.User

  @doc """
  Activates an User
  """
  @spec call(user :: Blog.User.t()) :: {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def call(user) do
    new()
    |> run(:user, &activate_user/2)
    |> transaction(Repo, user)
    |> case do
      {:ok, user, _effects} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Update User and set active to true
  """
  @spec activate_user(effects :: map, user :: Blog.User.t()) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def activate_user(_effects, %User{} = user) do
    user
    |> User.changeset(%{active: true})
    |> Repo.update()
  end
end
