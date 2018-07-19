defmodule Blog.User do
  use Blog, :schema

  @required [:email, :hashed_password, :access_token]
  @optional [:password, :name, :active]

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :active, :boolean, default: false
    field :access_token, :string

    has_many :posts, Blog.Post

    timestamps()
  end

  @spec changeset(struct :: struct, params :: map) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unsafe_validate_unique([:email], Repo)
    |> unique_constraint(:email)
  end
end
