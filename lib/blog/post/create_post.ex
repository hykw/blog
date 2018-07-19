defmodule Blog.Post.CreatePost do
  use Blog, :command

  alias Blog.{Post, Random}

  @doc """
  Create a new Post
  """
  @impl true
  @spec call(params :: map) :: {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def call(params) when is_map(params) do
    new()
    |> run(:handle, &generate_handle/2)
    |> run(:post, &create_post/2)
    |> transaction(Repo, params)
    |> case do
      {:ok, post, _effects} -> {:ok, post}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Generate a random handle if none was set
  """
  @spec generate_handle(effects :: map, params :: map) :: {:ok, String.t()}
  def generate_handle(_effects, %{handle: handle}) when not is_nil(handle) do
    {:ok, handle}
  end

  def generate_handle(_effects, _params) do
    {:ok, Random.generate_handle()}
  end

  @doc """
  Create Post
  """
  @spec create_post(effects :: map, params :: map) ::
          {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def create_post(effects, params) do
    params = Map.merge(params, Map.take(effects, [:handle]))

    %Post{}
    |> Post.changeset(params)
    |> Repo.insert()
  end
end
