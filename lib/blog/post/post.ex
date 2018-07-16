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
    |> put_handle_change()
    |> validate_required(@required)
  end

  @spec put_handle_change(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_handle_change(%{valid?: true} = changeset) do
    case get_field(changeset, :handle) do
      nil -> put_change(changeset, :handle, EntropyString.large())
      _handle -> changeset
    end
  end

  defp put_handle_change(changeset), do: changeset
end
