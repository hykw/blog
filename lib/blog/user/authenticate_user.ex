defmodule Blog.User.AuthenticateUser do
  use Blog, :command

  alias Blog.{Authentication, Repo, User}

  @doc """
  Authenticate an User
  """
  @spec call(args :: {email :: String.t(), password :: String.t()}) ::
          {:ok, Blog.User.t()} | {:error, any}
  def call(args) do
    new()
    |> run(:user, &find_user_by_email/2, &dummy_password_circuit_breaker/4)
    |> run(:password, &verify_password/2)
    |> execute(args)
    |> case do
      {:ok, true, %{user: user}} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Find an User by email
  """
  @spec find_user_by_email(effects :: map, args :: {email :: String.t(), password :: String.t()}) ::
          {:ok, Blog.User.t()} | {:error, Ecto.Changeset.t()}
  def find_user_by_email(_effects, {email, _password}) do
    case Repo.get_by(User, email: email, active: true) do
      nil -> {:error, :authentication_failed}
      user -> {:ok, user}
    end
  end

  @doc """
  Verify password against the user's hashed_password
  """
  @spec verify_password(effects :: map, args :: {email :: String.t(), password :: String.t()}) ::
          {:ok, boolean} | {:error, atom}
  def verify_password(%{user: user}, {_email, password}) do
    case Authentication.check_password(password, user.hashed_password) do
      true -> {:ok, true}
      _ -> {:error, :authentication_failed}
    end
  end

  @doc """
  Password circuit breaker
  """
  @spec dummy_password_circuit_breaker(
          effect_to_compensate :: map,
          effects_so_far :: map,
          name_and_reason :: {atom, any},
          args :: tuple
        ) :: atom
  def dummy_password_circuit_breaker(
        _effect_to_compensate,
        _effects_so_far,
        _name_and_reason,
        _args
      ) do
    Authentication.dummy_check_password()
    :abort
  end
end
