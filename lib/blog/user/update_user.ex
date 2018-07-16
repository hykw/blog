defmodule Blog.User.UpdateUser do
  use Blog, :command

  alias Blog.User

  @doc """
  Update an existing User
  """
  @impl true
  @spec call(args :: {params :: map, struct :: Blog.User.t()}) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def call({params, %User{}} = args) when is_map(params) do
    new()
    |> run(:user, &update_user/2)
    |> transaction(Repo, args)
    |> case do
      {:ok, user, _effects} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Update User
  """
  @spec update_user(effects :: map, args :: {params :: map, struct :: Blog.User.t()}) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(_effects, {params, user}) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
