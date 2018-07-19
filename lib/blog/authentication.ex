defmodule Blog.Authentication do
  @doc """
  Check the password against the hashed_password
  """
  defdelegate check_password(password, hashed_password), to: Comeonin.Bcrypt, as: :checkpw

  @doc """
  Dummy check password
  """
  defdelegate dummy_check_password, to: Comeonin.Bcrypt, as: :dummy_checkpw

  @doc """
  Hash the password
  """
  defdelegate hash_password(password), to: Comeonin.Bcrypt, as: :hashpwsalt
end
