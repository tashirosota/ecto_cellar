defmodule Post do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  schema "posts" do
    field(:title, :string)
    field(:views, :integer)

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :views])
    |> validate_required([:title, :views])
  end
end
