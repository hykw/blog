defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :api do
    plug BlogWeb.Token
  end

  scope "/graphiql" do
    pipe_through(:api)

    forward "/", Absinthe.Plug.GraphiQL,
      schema: BlogAPI.Schema,
      interface: :playground,
      analyze_complexity: true,
      max_complexity: 1000,
      json_codec: Jason
  end

  scope "/" do
    pipe_through(:api)

    forward "/", Absinthe.Plug,
      schema: BlogAPI.Schema,
      analyze_complexity: true,
      max_complexity: 1000,
      json_codec: Jason
  end
end
