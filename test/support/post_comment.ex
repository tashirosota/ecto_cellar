defmodule PostComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_comments" do
    field(:content, :string)
    field(:virtual, :string, virtual: true)

    belongs_to(:post, Post)

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required([:content, :post_id])
  end
end
