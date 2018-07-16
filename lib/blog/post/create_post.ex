defmodule Blog.Post.CreatePost do
  use Blog, :command

  alias Blog.Post

  @doc """
  Create a new Post
  """
  @impl true
  @spec call(params :: map) :: {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def call(params) when is_map(params) do
    new()
    |> run(:post, &create_post/2)
    |> transaction(Repo, params)
    |> case do
      {:ok, post, _effects} -> {:ok, post}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Create Post
  """
  @spec create_post(effects :: map, params :: map) ::
          {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def create_post(_effects, params) do
    %Post{}
    |> Post.changeset(params)
    |> Repo.insert()
  end
end
