defmodule BlogAPI.Schema.UserTypes do
  use BlogAPI, :type

  alias Blog.User
  alias Blog.User.{RegisterUser, UpdateUser, AuthenticateUser, ActivateUser}
  alias BlogAPI.Token

  connection(node_type: :user)

  node object(:user) do
    field :email, :string
    field :name, :string
    field :access_token, :string
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
    """
    payload field :login_user do
      input do
        field :email, non_null(:string)
        field :password, non_null(:string)
      end

      output do
        field :token, :string
        field :user, :user
      end

      resolve fn %{email: email, password: password}, _info ->
        with {:ok, %User{id: user_id} = user} <- AuthenticateUser.call({email, password}) do
          {:ok, %{user: user, token: Token.sign(user_id)}}
        end
      end

      middleware HandleToken, from_result: true
    end

    @desc """
    Register a new User
    """
    payload field(:register_user) do
      input do
        import_fields :user_input
      end

      output do
        field :message, :string
      end

      resolve fn params, _info ->
        with {:ok, _user} <- RegisterUser.call(params) do
          {:ok, %{message: "User registered, email sent"}}
        end
      end
    end

    @desc """
    Activate User
    """
    payload field :activate_user do
      input do
        field :email, non_null(:string)
        field :access_token, non_null(:string)
      end

      output do
        field :message, :string
      end

      resolve fn %{email: email, access_token: access_token}, _info ->
        with {:ok, user} <- Repo.find_by(User, email: email, access_token: access_token),
             {:ok, _user} <- ActivateUser.call(user) do
          {:ok, %{message: "User activated"}}
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

      resolve fn params, %{context: %{user: user}} ->
        with {:ok, user} <- UpdateUser.call({params, user}) do
          {:ok, %{user: user}}
        end
      end
    end
  end
end
