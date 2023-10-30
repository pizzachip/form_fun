defmodule FormFun.FormFields do
  use Ecto.Schema
  import Ecto.Changeset
  alias FormFun.Animal

  embedded_schema do
    field :name, :string
    field :age, :integer
    embeds_many :animals, Animal
  end

  def changeset(form_fields, params \\ %{}) do
    form_fields
    |> cast(params, [:name, :age])
    |> cast_embed(:animals)
    |> validate_required([:name, :age])
  end
end
