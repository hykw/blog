defmodule Blog.Command do
  @callback call(args :: any) :: {:ok, any} | {:error, any}
end
