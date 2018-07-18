defmodule BlogAPI.HandleToken do
  use BlogAPI, :middleware

  alias Blog.{Repo, User}
  alias BlogAPI.Token

  @doc """
  Handle Token
  """
  @spec call(resolution :: Absinthe.Resolution.t(), config :: any) :: Absinthe.Resolution.t()
  def call(resolution, config)

  @doc """
  Absinthe context contains an token, create a env context
  """
  def call(%{context: %{token: token} = context} = resolution, _config) do
    with {:ok, user} <- create_user_from_token(token) do
      %{resolution | context: Map.put(context, :user, user)}
    else
      {:error, :authentication_session_expired} = error ->
        Resolution.put_result(resolution, error)

      _ ->
        Resolution.put_result(resolution, {:error, :unauthenticated})
    end
  end

  def call(%{value: value, context: context} = resolution, from_result: true) do
    with %{user: %User{} = user} <- value do
      %{resolution | context: Map.put(context, :user, user)}
    else
      _ -> resolution
    end
  end

  @doc """
  Absinthe context already contains a session, do nothing
  """
  def call(%{context: %{env: %{session: session}}} = resolution, _config)
      when not is_nil(session) do
    resolution
  end

  @doc """
  Token or session is missing from context, set an error
  """
  def call(resolution, _config) do
    Resolution.put_result(resolution, {:error, :authentication_token_missing})
  end

  @spec create_user_from_token(token :: String.t()) :: {:ok, BlogAPI.Env.t()} | {:error, any}
  defp create_user_from_token(token) do
    with {:ok, user_id} <- Token.verify(token) do
      Repo.find(User, user_id)
    end
  end
end
