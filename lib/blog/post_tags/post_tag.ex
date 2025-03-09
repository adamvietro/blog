# defmodule Blog.Post_Tags.Post_Tag do
#   alias Blog.Post_Tags.Post_Tag
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key false
#   schema "post_tags" do
#     field :post_id, :id
#     field :tag_id, :id
#   end

#   @doc false
#   def changeset(post_tag, attrs) do
#     post_tag
#     |> cast(attrs, [:post_id, :tag_id])
#     |> validate_required([:post_id, :tag_id])

#   end
# end
