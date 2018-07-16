defmodule Blog do
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
