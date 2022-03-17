defmodule EctoCellarTest do
  use ExUnit.Case
  # use DataCase
  @repo Application.get_env(:ecto_cellar, :repo)
  setup do
    {:ok, post} = %Post{title: "title", views: 0} |> @repo.insert()

    {:ok, article} =
      %Article{uuid: Ecto.UUID.generate(), title: "title", views: 0} |> @repo.insert()

    [post: post, article: article]
  end

  describe "store/2" do
    test "return {:ok, model}", %{post: post, article: article} do
      {:ok, %Post{title: "title", views: 0}} = EctoCellar.store(post)
      {:ok, %Article{title: "title", views: 0}} = EctoCellar.store(article, :uuid)
    end

    test "return {:error, term}", %{post: post, article: article} do
      {:error, %{errors: [model_id: {"can't be blank", [validation: :required]}]}} =
        EctoCellar.store(post |> Map.put(:id, nil))

      {:error, %{errors: [model_id: {"can't be blank", [validation: :required]}]}} =
        EctoCellar.store(article |> Map.put(:uuid, nil), :uuid)
    end
  end

  describe "store!/2" do
    test "return {:ok, model}", %{post: post, article: article} do
      %Post{title: "title", views: 0} = EctoCellar.store!(post)

      %Article{title: "title", views: 0} = EctoCellar.store!(article, :uuid)
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

      :ok
    end

    test "return models", %{post: post, article: article} do
      assert EctoCellar.all(post) |> Enum.count() >= 10
      assert EctoCellar.all(article, :uuid) |> Enum.count() >= 10
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

      assert ^expected_article = restored = EctoCellar.one(article, article.inserted_at, :uuid)
      assert {:ok, _} = restored |> Article.changeset(%{}) |> @repo.update()
    end
  end
end
