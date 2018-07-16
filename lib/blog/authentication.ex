defmodule Blog.Authentication do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Blog.{Repo, User}
  alias Blog.User.UserQueries

  @doc """
  Authenticate a user by email and password
  """
  @spec authenticate_user(email :: String.t(), password :: String.t()) ::
          {:ok, User.t()} | {:error, message :: atom}
  def authenticate_user(email, password) do
    user =
      email
      |> UserQueries.user_by_email()
      |> UserQueries.filter_active(true)
      |> Repo.one()

    user_password =
      case user do
        nil -> nil
        user -> user.hashed_password
      end

    with :ok <- validate_password(password, user_password) do
      {:ok, user}
    end
  end

  @doc """
  Validate password
  """
  @spec validate_password(password :: String.t(), hashed_password :: String.t()) ::
          :ok | {:error, message :: atom}
  def validate_password(password, hashed_password)
      when is_nil(password) or is_nil(hashed_password) do
    dummy_checkpw()
    {:error, :authentication_failed}
  end

  def validate_password(password, hashed_password) do
    case checkpw(password, hashed_password) do
      true -> :ok
      _ -> {:error, :authentication_failed}
    end
  end

  @doc """
  Hash the password
  """
  @spec hash_password(password :: String.t()) :: String.t() | {:error, any()}
  defdelegate hash_password(password), to: Comeonin.Bcrypt, as: :hashpwsalt
end
