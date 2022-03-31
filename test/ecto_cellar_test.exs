defmodule EctoCellarTest do
  use ExUnit.Case
  # use DataCase
  @repo Application.get_env(:ecto_cellar, :default_repo)
  setup do
    {:ok, post} = %Post{title: "title", views: 0} |> Post.changeset(%{}) |> @repo.insert()

    {:ok, article} =
      %Article{uuid: Ecto.UUID.generate(), title: "title", views: 0} |> @repo.insert()

    [post: post, article: article]
  end

  describe "store/2" do
    test "return {:ok, model}", %{post: post, article: article} do
      assert {:ok, %Post{title: "title", views: 0}} = EctoCellar.store(post)
      assert {:ok, %Article{title: "title", views: 0}} = EctoCellar.store(article, :uuid)
      assert {:ok, %Article{title: "title", views: 0}} = EctoCellar.store(article)
    end

    test "return {:error, term}", %{post: post, article: article} do
      assert {:error, %{errors: [model_id: {"can't be blank", [validation: :required]}]}} =
               EctoCellar.store(post |> Map.put(:id, nil))

      assert {:error, %{errors: [model_id: {"can't be blank", [validation: :required]}]}} =
               EctoCellar.store(article |> Map.put(:uuid, nil), :uuid)
    end

    test "can pass othre repo", %{post: post} do
      assert_raise UndefinedFunctionError,
                   "function :dummy.insert/1 is undefined (module :dummy is not available)",
                   fn ->
                     EctoCellar.store(post, repo: :dummy)
                   end
    end
  end

  describe "store!/2" do
    test "return {:ok, model}", %{post: post, article: article} do
      assert %Post{title: "title", views: 0} = EctoCellar.store!(post)

      assert %Article{title: "title", views: 0} = EctoCellar.store!(article, :uuid)
    end

    test "raise Ecto.InvalidChangesetError", %{post: post, article: article} do
      assert_raise Ecto.InvalidChangesetError,
                   fn ->
                     EctoCellar.store!(post |> Map.put(:id, nil))
                   end

      assert_raise Ecto.InvalidChangesetError,
                   fn ->
                     EctoCellar.store!(article |> Map.put(:uuid, nil), :uuid)
                   end
    end
  end

  describe "insert_and_store/3" do
    setup do
      [
        post: %Post{title: "title", views: 0},
        article: %Article{uuid: Ecto.UUID.generate(), title: "title", views: 0}
      ]
    end

    test "return {:ok, model}", %{post: post, article: article} do
      assert {:ok, %Post{title: "title", views: 0}} = EctoCellar.insert_and_store(post)

      assert {:ok, %Article{title: "title", views: 0}} = EctoCellar.insert_and_store(article)
    end
  end

  describe "update_and_store/3" do
    setup do
      {:ok, post} = %Post{title: "title", views: 0} |> @repo.insert()

      {:ok, article} =
        %Article{uuid: Ecto.UUID.generate(), title: "title", views: 0} |> @repo.insert()

      [
        post: post |> Map.put(:views, 1) |> Post.changeset(%{}),
        article: article |> Map.put(:views, 1) |> Article.changeset(%{})
      ]
    end

    test "return {:ok, model}", %{post: post, article: article} do
      assert {:ok, %Post{title: "title", views: 1}} = EctoCellar.update_and_store(post)

      assert {:ok, %Article{title: "title", views: 1}} = EctoCellar.update_and_store(article)
    end
  end

  describe "insert_or_update_and_store/3" do
    setup do
      [
        post: %Post{title: "title", views: 0} |> Post.changeset(%{}),
        article:
          %Article{uuid: Ecto.UUID.generate(), title: "title", views: 0} |> Article.changeset(%{})
      ]
    end

    test "return {:ok, model}", %{post: post, article: article} do
      assert {:ok, %Post{title: "title", views: 0} = post} =
               EctoCellar.insert_or_update_and_store(post)

      assert {:ok, %Post{title: "title", views: 1} = post} =
               post |> Post.changeset(%{views: 1}) |> EctoCellar.insert_or_update_and_store()

      assert {:ok, %Article{title: "title", views: 0} = article} =
               EctoCellar.insert_or_update_and_store(article)

      assert {:ok, %Article{title: "title", views: 1} = article} =
               article
               |> Article.changeset(%{views: 1})
               |> EctoCellar.insert_or_update_and_store(id_type: :uuid)
    end
  end

  describe "all/2" do
    setup ctx do
      0..10
      |> Enum.each(fn _ ->
        {:ok, _} = EctoCellar.store(ctx[:post])
      end)

      0..10
      |> Enum.each(fn _ ->
        {:ok, _} = EctoCellar.store(ctx[:article], :uuid)
      end)

      0..10
      |> Enum.each(fn _ ->
        {:ok, _} = EctoCellar.store(ctx[:article])
      end)

      :ok
    end

    test "return models", %{post: post, article: article} do
      assert EctoCellar.all(post) |> Enum.count() >= 10
      assert EctoCellar.all(article, :uuid) |> Enum.count() >= 10
      assert EctoCellar.all(article) |> Enum.count() >= 10
    end
  end

  describe "one/2" do
    setup ctx do
      %Post{title: "title", views: 0} = EctoCellar.store!(ctx[:post])
      %Article{title: "title", views: 0} = EctoCellar.store!(ctx[:article], :uuid)
      :ok
    end

    test "return model", %{post: post, article: article} do
      expected_post = %Post{
        id: post.id,
        title: post.title,
        views: post.views,
        inserted_at: post.inserted_at,
        updated_at: post.updated_at
      }

      assert ^expected_post = restored = EctoCellar.one(post, post.inserted_at)
      assert {:ok, _} = restored |> Post.changeset(%{}) |> @repo.update()

      expected_article = %Article{
        uuid: article.uuid,
        title: article.title,
        views: article.views,
        inserted_at: article.inserted_at,
        updated_at: article.updated_at
      }

      assert ^expected_article = EctoCellar.one(article, article.inserted_at, :uuid)

      assert ^expected_article = restored = EctoCellar.one(article, article.inserted_at)

      assert {:ok, _} = restored |> Article.changeset(%{}) |> @repo.update()
    end
  end

  describe "only versions non-virtual field names" do
    setup ctx do
      {:ok, comment} =
        %PostComment{content: "a comment", post_id: ctx.post.id, virtual: "not versioned"}
        |> @repo.insert()

      [comment: comment]
    end

    test "store does not cause Jason RuntimeError with associated fields", %{comment: comment} do
      assert {:ok, _} = EctoCellar.store(comment)
    end

    test "stored version does not include associated or virtual fields", %{comment: comment} do
      assert %PostComment{post: %Post{}} = preloaded = @repo.preload(comment, :post)

      assert %PostComment{} = EctoCellar.store!(preloaded)

      assert %PostComment{post: %Ecto.Association.NotLoaded{}, virtual: nil} =
               EctoCellar.one(preloaded, preloaded.inserted_at)
    end
  end
end
