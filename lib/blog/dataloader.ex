defmodule Blog.Dataloader do
  alias Blog.{Repo, Query}

  @doc """
  Create new Dataloader and add sources
  """
  @spec new() :: Dataloader.t()
  def new do
    source = Dataloader.Ecto.new(Repo, query: &Query.filter/2)

    Dataloader.new()
    |> Dataloader.add_source(:db, source)
  end
end
