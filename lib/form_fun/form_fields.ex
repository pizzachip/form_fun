defmodule FormFun.FormFields do
  use Ecto.Schema
  import Ecto.Changeset
  alias FormFun.Animals

  embedded_schema do
    field :name, :string, default: ""
    field :age, :integer
    embeds_many :animals, Animals
  end

  def changeset(form_fields, params \\ %{}) do
    form_fields
    |> cast(params, [:name, :age])
    |> cast_embed(:animals)
  end
end
