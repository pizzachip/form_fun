defmodule FormFun.Animal do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :animal_id, :integer
    field :name, :string
    field :qty, :integer, default: 0
    field :chosen, :boolean
  end

  def changeset(animals, params \\ %{}) do
    animals
    |> cast(params, [:animal_id, :name, :qty, :chosen])
    |> validate_required([:animal_id, :name, :qty, :chosen])
  end
end
