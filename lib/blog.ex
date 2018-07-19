defmodule Blog do
  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      alias Blog.Repo

      @type t :: %__MODULE__{}

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def command do
    quote do
      import Sage

      @behaviour Blog.Command

      alias Blog.Repo
    end
  end

  def email do
    quote do
      import Swoosh.Email
    end
  end

  def query do
    quote do
      import Ecto.Query, only: [from: 2]
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def config(key) do
    Application.get_env(:blog, key)
  end
end
