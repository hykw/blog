defmodule Blog.User do
  use Blog, :schema

  alias Blog.Authentication

  @required [:email, :hashed_password]
  @optional [:password, :name]

  @register_required [:name, :email, :password, :hashed_password]

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :active, :boolean, default: false

    has_many :posts, Blog.Post

    timestamps()
  end

  @spec changeset(struct :: struct, params :: map) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @required ++ @optional)
    |> put_hashed_password_change()
    |> validate_required(@required)
  end

  @spec register_changeset(struct :: struct, params :: map) :: Ecto.Changeset.t()
  def register_changeset(struct, params) do
    struct
    |> cast(params, @register_required)
    |> put_hashed_password_change()
    |> validate_required(@register_required)
  end

  @spec put_hashed_password_change(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_hashed_password_change(%{valid?: true} = changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :hashed_password, Authentication.hash_password(password))
    end
  end

  defp put_hashed_password_change(changeset), do: changeset
end
