defmodule Article do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:uuid, :string, []}

  schema "articles" do
    field(:title, :string)
    field(:views, :integer)

    timestamps()
  end

  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :views])
    |> validate_required([:title, :views])
  end
end
