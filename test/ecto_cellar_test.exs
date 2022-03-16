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
  end

  describe "store!/2" do
    test "return {:ok, model}", %{post: post, article: article} do
      %Post{title: "title", views: 0} =
        EctoCellar.store!(post)
        |> IO.inspect()

      %Article{title: "title", views: 0} = EctoCellar.store!(article, :uuid)
    end
  end

  describe "one/2" do
  end

  describe "one/3" do
  end

  describe "all/2" do
  end

  describe "all/3" do
  end
end
