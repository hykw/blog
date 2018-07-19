defmodule BlogAPI.Schema.PostTypes do
  use BlogAPI, :type

  alias Blog.{Post, User}
  alias Blog.Post.{PostQueries, CreatePost, UpdatePost}

  connection(node_type: :post)

  node object(:post) do
    field :title, :string
    field :handle, :string
    field :content, :string
    field :published_at, :naive_datetime

    field :user, :user do
      resolve dataloader(:db)
    end
  end

  input_object :post_input do
    field :title, :string
    field :handle, :string
    field :content, :string
    field :published_at, :naive_datetime
  end

  enum :sort_order do
    value :asc
    value :desc
  end

  input_object :post_filter do
    field :type, :string
    field :published, :boolean
  end

  input_object :post_sort_order do
    field :published_at, :sort_order
    field :inserted_at, :sort_order
    field :updated_at, :sort_order
  end

  object :post_queries do
    @desc """
    Get Post by handle
    """
    field :post_by_handle, :post do
      arg :access_token, non_null(:string)
      arg :handle, non_null(:string)

      resolve fn %{access_token: access_token, handle: handle}, _info ->
        with {:ok, %User{} = user} <- Repo.find_by(User, access_token: access_token),
             {:ok, %Post{} = post} <- Repo.find_by(Post, user_id: user.id, handle: handle) do
          {:ok, post}
        else
          _ -> {:ok, nil}
        end
      end
    end

    @desc """
    Fetch all Posts by User
    """
    connection field(:posts_by_user, node_type: :post) do
      arg :filter, :post_filter
      arg :order, :post_sort_order

      resolve fn args, %{context: %{user: user}} ->
        query =
          user.id
          |> PostQueries.posts_by_user()
          |> Query.filter(args)

        Connection.from_query(query, &Repo.all/1, args)
      end
    end

    @desc """
    Fetch all Posts by access token
    """
    connection field(:posts_by_access_token, node_type: :post) do
      arg :access_token, non_null(:string)
      arg :filter, :post_filter
      arg :order, :post_sort_order

      resolve fn args, _info ->
        {access_token, args} = Map.pop(args, :access_token)

        with {:ok, user} <- Repo.find_by(User, access_token: access_token) do
          query =
            user.id
            |> PostQueries.posts_by_user()
            |> Query.filter(args)

          Connection.from_query(query, &Repo.all/1, args)
        end
      end
    end
  end

  object :post_mutations do
    @desc """
    Create a new Post
    """
    payload field(:create_post) do
      input do
        import_fields :post_input
      end

      output do
        field :post, :post
      end

      resolve fn args, %{context: %{user: user}} ->
        params = Map.put(args, :user_id, user.id)

        with {:ok, post} <- CreatePost.call(params) do
          {:ok, %{post: post}}
        end
      end
    end

    @desc """
    Update an existing Post
    """
    payload field(:update_post) do
      input do
        field :post_id, non_null(:id)
        import_fields :post_input
      end

      output do
        field :post, :post
      end

      middleware ParseIDs, post_id: :post

      resolve fn args, %{context: %{user: user}} ->
        {post_id, params} = Map.pop(args, :post_id)

        with {:ok, post} <- Repo.find(Post, post_id),
             :ok <- can?(user, update(post)),
             {:ok, post} <- UpdatePost.call({params, post}) do
          {:ok, %{post: post}}
        end
      end
    end

    @desc """
    Delete an existing Post
    """
    payload field :delete_post do
      input do
        field :post_id, non_null(:id)
      end

      output do
        field :post, :post
      end

      middleware ParseIDs, post_id: :post

      resolve fn %{post_id: post_id}, %{context: %{user: user}} ->
        with {:ok, post} <- Repo.find(Post, post_id),
             :ok <- can?(user, delete(post)),
             {:ok, post} <- Repo.delete(post) do
          {:ok, %{post: post}}
        end
      end
    end
  end
end
