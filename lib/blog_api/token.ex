defmodule BlogAPI.Token do
  alias Phoenix.Token

  @salt Blog.config(:salt)
  @max_age 86400

  @doc """
  Sign a user id and return a token
  """
  @spec sign(user_id :: String.t()) :: String.t()
  def sign(user_id) do
    Token.sign(BlogWeb.Endpoint, @salt, user_id)
  end

  @doc """
  Verify the given token
  """
  @spec verify(token :: String.t()) :: {:ok, String.t()} | {:error, any}
  def verify(token) do
    Token.verify(BlogWeb.Endpoint, @salt, token, max_age: @max_age)
  end
end
