defmodule Blog.Post.UpdatePost do
  use Blog, :command

  alias Blog.Post

  @doc """
  Update an existing Post
  """
  @impl true
  @spec call(args :: {params :: map, struct :: Blog.Post.t()}) ::
          {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def call({params, %Post{}} = args) when is_map(params) do
    new()
    |> run(:post, &update_post/2)
    |> transaction(Repo, args)
    |> case do
      {:ok, post, _effects} -> {:ok, post}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Update Post
  """
  @spec update_post(effects :: map, args :: {params :: map, struct :: Blog.Post.t()}) ::
          {:ok, Blog.Post.t()} | {:error, Ecto.Changeset.t()}
  def update_post(_effects, {params, post}) do
    post
    |> Post.changeset(params)
    |> Repo.update()
  end
end
