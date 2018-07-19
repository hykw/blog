defmodule BlogAPI do
  def type do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern

      import Absinthe.Resolution.Helpers
      import BlogAPI.Helpers

      alias Absinthe.Relay.Connection
      alias Absinthe.Relay.Node.ParseIDs
      alias Blog.{Repo, Query}
      alias BlogAPI.HandleToken
    end
  end

  def middleware do
    quote do
      @behaviour Absinthe.Middleware

      alias Absinthe.Resolution
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
