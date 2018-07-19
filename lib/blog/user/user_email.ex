defmodule Blog.User.UserEmail do
  use Blog, :email

  def register(user) do
    new()
    |> to({user.name, user.email})
    |> from({"Blog", "noreply@blog.test"})
    |> subject("Access token")
    |> html_body("<h1>Hello #{user.name}</h1><p>Your access token is: #{user.access_token} </p>")
    |> text_body("Hello #{user.name}\n\nYour access token is: #{user.access_token}")
  end
end
