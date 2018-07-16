defmodule Blog.User.RegisterUser do
  use Blog, :command

  alias Blog.{User, Mailer}
  alias Blog.User.UserEmail

  @doc """
  Register a new User
  """
  @impl true
  @spec call(params :: map) :: {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def call(params) when is_map(params) do
    new()
    |> run(:user, &create_user/2)
    |> run(:email, &send_register_email/2)
    |> transaction(Repo, params)
    |> case do
      {:ok, _effect, %{user: user}} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Create User
  """
  @spec create_user(effects :: map, params :: map) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(_effects, params) do
    %User{}
    |> User.register_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Send register email
  """
  @spec send_register_email(effects :: map, params :: map) :: {:ok, any} | {:error, any}
  def send_register_email(%{user: user}, _params) do
    user
    |> UserEmail.register()
    |> Mailer.deliver()
  end
end
