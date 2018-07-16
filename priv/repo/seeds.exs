{:ok, user} =
  Blog.User.RegisterUser.call(%{
    name: "Jane Smith",
    email: "jane.smith@nada.email",
    password: "jane123"
  })

for i <- 1..10 do
  Blog.Post.CreatePost.call(%{
    user_id: user.id,
    title: "Post title #{i}"
  })
end
