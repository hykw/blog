defmodule Blog.Random do
  use EntropyString, charset: EntropyString.CharSet.charset32(), bits: 512

  @doc """
  Generate a token
  """
  @spec generate_token() :: String.t()
  defdelegate generate_token(), to: Blog.Random, as: :token

  @doc """
  Generate a handle
  """
  @spec generate_handle() :: String.t()
  defdelegate generate_handle(), to: Blog.Random, as: :medium
end
