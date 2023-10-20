defmodule FormFun.Animal do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :qty, :integer 
  end
end
