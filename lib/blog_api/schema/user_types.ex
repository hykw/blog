defmodule BlogAPI.Schema.UserTypes do
  use BlogAPI, :type

  alias Blog.User.{RegisterUser, UpdateUser}

  connection(node_type: :user)

  node object(:user) do
    field :email, :string
    field :name, :string
  end

  input_object :user_input do
    field :email, :string
    field :name, :string
    field :password, :string
  end

  object :user_queries do
    @desc """
    Get logged in User
    """
    field :current_user, :user do
      resolve fn _params, %{context: %{user: user}} ->
        {:ok, user}
      end
    end
  end

  object :user_mutations do
    @desc """
    Register a new User
    """
    payload field(:register_user) do
      input do
        import_fields :user_input
      end

      output do
        field :user, :user
      end

      resolve fn params, _info ->
        with {:ok, user} <- RegisterUser.call(params) do
          {:ok, %{user: user}}
        end
      end
    end

    @desc """
    Update an existing User
    """
    payload field(:update_user) do
      input do
        import_fields :user_input
      end

      output do
        field :user, :user
      end

      middleware ParseIDs, user_id: :user

      resolve fn params, %{context: %{user: user}} ->
        with {:ok, user} <- UpdateUser.call({params, user}) do
          {:ok, %{user: user}}
        end
      end
    end
  end
end
