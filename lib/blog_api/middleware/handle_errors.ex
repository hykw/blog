defmodule BlogAPI.HandleErrors do
  use BlogAPI, :middleware

  @errors %{
    # Not found
    not_found: %{
      message: "We were unable to find what you are looking for",
      hint:
        "We could not find the resource that you queried, maybe it does not exist or the shop has no access to it."
    },

    # Authentication and authorization
    authentication_failed: %{
      message: "Incorrect email or password",
      hint: "Either we couldn't find a user with a matching email, or the password doesn't match."
    },
    authentication_session_expired: %{
      message: "Your session has expired, please sign in again",
      hint: "The user's session has expired. You need to create a new session."
    },
    authentication_token_missing: %{
      message: "You need to sign in to do this",
      hint: "There was no authentication token sent with this request."
    },
    unauthenticated: %{
      message: "You need to sign in to do this",
      hint: "Either the token is invalid or has been revoked."
    },
    missing_permission: %{
      message: "You have insufficient permissions to do this",
      hint:
        "The current user cannot perform this operation because they lack the required permissions to do so."
    }
  }

  @doc """
  Handle Errors
  """
  @spec call(resolution :: Absinthe.Resolution.t(), config :: any) :: Absinthe.Resolution.t()
  def call(%{errors: [error_code]} = resolution, _config) when is_atom(error_code) do
    error =
      case Map.get(@errors, error_code) do
        %{message: error_message, hint: error_hint} ->
          %{
            code: error_code,
            message: error_message,
            hint: error_hint
          }

        _unknown_error ->
          %{
            code: error_code,
            message: "Unknown error occured (#{error_code})",
            hint: "This error isn't documented, please contact us."
          }
      end

    Resolution.put_result(resolution, {:error, error})
  end

  def call(%{errors: [%Ecto.Changeset{} = changeset]} = resolution, _opts) do
    Resolution.put_result(resolution, {:error, transform_changeset(changeset)})
  end

  def call(resolution, _config) do
    resolution
  end

  @spec transform_changeset(changeset :: Ecto.Changeset.t()) :: list
  defp transform_changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> transform_errors()
    |> List.flatten()
  end

  @spec transform_errors(errors :: Enumerable.t(), path :: Enumerable.t()) :: any
  defp transform_errors(errors, path \\ []) do
    Enum.map(errors, fn
      %{message: message, validation: validation} ->
        %{
          message: message,
          validation: validation,
          key: Enum.reverse(path)
        }

      # Handle multiple errors
      {field, errors} when is_map(errors) or is_list(errors) ->
        transform_errors(errors, [field | path])

      # Nested changeset errors
      error when is_map(error) ->
        transform_errors(error, path)
    end)
  end

  @spec format_error({msg :: any, opts :: Enumerable.t()}) :: Collectable.t()
  defp format_error({msg, opts}) do
    message =
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", inspect(value))
      end)

    Enum.into(opts, %{message: message})
  end
end
