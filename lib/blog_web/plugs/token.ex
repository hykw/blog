defmodule BlogWeb.Token do
  import Plug.Conn

  @doc """
  Initialize plug
  """
  @spec init(opts :: any) :: any
  def init(opts), do: opts

  @doc """
  Parse token and set in context
  """
  @spec call(conn :: Plug.Conn.t(), opts :: any) :: Plug.Conn.t()
  def call(conn, _opts) do
    with {:ok, token} <- parse_token(conn) do
      res =
        case conn.private[:absinthe] do
          nil -> %{context: %{token: token}}
          res -> put_in(res, [:context, :token], token)
        end

      put_private(conn, :absinthe, res)
    else
      _ -> conn
    end
  end

  # Parse the token from the request headers
  @spec parse_token(conn :: Plug.Conn.t()) :: {:ok, String.t()} | {:error, atom}
  defp parse_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, :not_found}
    end
  end
end
