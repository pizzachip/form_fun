defmodule FormFunWeb.Home do
  use FormFunWeb, :live_view
  import FormFun.Components.Text
  import Ecto.Changeset
  import Phoenix.HTML.Form
  alias FormFun.{FormFields, Animal}

  def render(assigns) do
    ~H"""
    <.body>
      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} label="Name"/>
        <.input field={@form[:age]} label="Age" />
        <.input field={@form[:animals]} label="Animals" type="select" multiple={true} options={animal_options(@animals)} />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>

      <div><%= @last_input.name %></div>
      <div><%= @last_input.age %></div>
      <%= for animal <- @last_input.animals do %>
        <div><%= animal.name  %></div>
        <div><%= animal.qty  %></div>
      <% end %>
    </.body>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    assigns =
      socket
      |> assign(:page_title, "New Form Fun")
      |> assign(:last_input, %FormFields{name: "Your Name", age: 18, animals: []})
      |> assign(:form_valid, false)
      |> assign(:animals, initial_animals())
      |> assign(:form, my_form(%FormFields{name: nil, age: nil, animals: []}))

    {:ok, assigns}
  end

  @impl true
  def handle_event("save", %{"form_fields" => params}, socket) do
    animals = translate_animals(params["animals"], socket.assigns.animals)
    new_params = 
      %FormFields{}
      |> FormFields.changeset(Map.merge(params, %{"animals" => animals}))
      |> apply_changes


    {:noreply, 
      socket
      |> assign(:form_fields, new_params)
      |> assign(:last_input, new_params) 
    }
  end

  @impl true
  def handle_event("validate", %{"form_fields" => params}, socket) do
    animals = translate_animals(params["animals"] || [], socket.assigns.animals)

    myform = FormFields.changeset(%FormFields{}, Map.merge(params, %{"animals" => animals})) 

    if myform.valid? do
      {:noreply, assign(socket, %{form_valid: true})}
    else

      errors = myform.errors 
             |> Enum.map(fn { field, { message, _ }} -> {field, message} end)
             |> IO.inspect(label: "my form values")
             
      {:noreply,
        socket
        |> assign(%{form_valid: false})
      }

    end
  end

  @spec my_form(%FormFields{}) :: Phoenix.HTML.Form.t()
  def my_form(form_fields) do
    form_fields 
    |> FormFields.changeset 
    |> to_form 
  end

  @spec initial_animals() :: [Animal.t()]
  def initial_animals() do
    for animal <- ["Dog", "Cat", "Giraffe"], reduce: [] do
      acc -> [%Animal{id: length(acc) + 1, name: animal, qty: 2} | acc]
    end
  end

  @spec animal_options([Animal.t()]) :: [String.t()]
  def animal_options(animals) do
    Enum.reduce(animals, [], fn animal, acc -> [ {animal.name, animal.id} | acc] end)
  end

  @spec translate_animals([String.t()], [Animal.t()]) :: [map()] 
  def translate_animals(form_animals, animal_collection) do
    IO.inspect({form_animals, animal_collection})

    form_animals
    |> Enum.map(fn id -> id |> String.to_integer end )
    |> Enum.map(fn x -> Enum.reduce(animal_collection, [], fn y, acc -> if x == y.id, do: y, else: acc end) end) 
    |> Enum.map(fn animal -> animal |> Map.from_struct end )
  end
end
