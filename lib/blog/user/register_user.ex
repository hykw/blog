defmodule Blog.User.RegisterUser do
  use Blog, :command

  alias Blog.{User, Mailer, Authentication, Random}
  alias Blog.User.UserEmail

  @doc """
  Register a new User
  """
  @impl true
  @spec call(params :: map) :: {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def call(params) when is_map(params) do
    new()
    |> run(:hashed_password, &hash_password/2)
    |> run(:access_token, &generate_access_token/2)
    |> run(:user, &create_user/2)
    |> run(:email, &send_register_email/2)
    |> transaction(Repo, params)
    |> case do
      {:ok, _effect, %{user: user}} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """

  """
  @spec hash_password(effects :: map, params :: map) :: {:ok, String.t()} | {:error, any}
  def hash_password(_effects, %{password: password}) do
    {:ok, Authentication.hash_password(password)}
  end

  def hash_password(_effects, _params), do: {:error, "Password is missing"}

  @spec generate_access_token(effects :: map, params :: map) :: {:ok, String.t()}
  def generate_access_token(_effects, _params) do
    {:ok, Random.generate_token()}
  end

  @doc """
  Create User
  """
  @spec create_user(effects :: map, params :: map) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(effects, params) do
    params = Map.merge(params, Map.take(effects, [:hashed_password, :access_token]))

    %User{}
    |> User.changeset(params)
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
