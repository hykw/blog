defmodule BlogWeb.Router do
  use BlogWeb, :router

  if Mix.env() == :dev do
    pipeline :browser do
      plug :accepts, ["html"]
    end

    scope "/dev" do
      pipe_through(:browser)

      forward "/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox"
    end
  end

  pipeline :api do
    plug BlogWeb.Token
  end

  scope "/graphiql", host: "api.blog.test" do
    pipe_through(:api)

    forward "/", Absinthe.Plug.GraphiQL,
      schema: BlogAPI.Schema,
      interface: :playground,
      analyze_complexity: true,
      max_complexity: 1000,
      json_codec: Jason
  end

  scope "/", host: "api.blog.test" do
    pipe_through(:api)

    forward "/", Absinthe.Plug,
      schema: BlogAPI.Schema,
      analyze_complexity: true,
      max_complexity: 1000,
      json_codec: Jason
  end
end
