defmodule FormFun.Animal do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :qty, :integer 
  end

  def changeset(animals, params \\ %{}) do
    animals
    |> cast(params, [:name, :qty])
  end
end
