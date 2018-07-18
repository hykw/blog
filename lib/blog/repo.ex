defmodule Blog.Repo do
  use Ecto.Repo, otp_app: :blog

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Tries to find a record by given module and id
  Returns {:ok, struct} or {:error, :not_found}
  """
  @spec find(queryable :: Ecto.Queryable.t(), id :: any, opts :: Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, atom}
  def find(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end

  @doc """
  Tries to find a record by given module and clauses
  Returns {:ok, struct} or {:error, :not_found}
  """
  @spec find_by(queryable :: Ecto.Queryable.t(), clauses :: Keyword.t(), opts :: Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, atom}
  def find_by(queryable, clauses, opts \\ []) do
    case get_by(queryable, clauses, opts) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end
end
