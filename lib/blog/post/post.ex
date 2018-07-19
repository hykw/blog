defmodule Blog.Post do
  use Blog, :schema

  @required [:title, :handle, :user_id]
  @optional [:content, :published_at]

  schema "posts" do
    field :title, :string
    field :handle, :string
    field :content, :string
    field :published_at, :naive_datetime

    belongs_to :user, Blog.User

    timestamps()
  end

  @spec changeset(struct :: struct, params :: map) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unsafe_validate_unique([:user_id, :handle], Repo)
    |> unique_constraint(:handle, name: :posts_user_id_handle_index)
  end
end
