defmodule FormFunWeb.Home do
  use FormFunWeb, :live_view
  import FormFunWeb.Flash
  import FormFun.Components.Text
  import Ecto.Changeset
  alias FormFun.{FormFields, Animal}

  @impl true
  def render(assigns) do
    ~H"""
    <.body>
      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} label="Name"/>
        <.input field={@form[:age]} type="number" min="0" max="120" label="Age" />
          <label for="form_fields_animals" class="block text-sm font-semibold leading-6 text-zinc-800">Animals Label</label>
            <%= for animal <- @animals do %>
              <.input name={"form_fields[animals]["<>animal.name<>"][chosen]"} type="checkbox" value="false" />
              <.input name={"form_fields[animals]["<>animal.name<>"][qty]"} value={animal.qty} label={animal.name} type="number" />  
            <% end %>
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>

      <div><%= @last_input.name %></div>
      <div><%= @last_input.age %></div>
      <%= for animal <- @last_input.animals do %>
        <div><%= animal.name %></div>
        <div><%= animal.qty %></div>
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
  def handle_event("save", params, socket) do
    IO.inspect(params, label: "params save")
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
      put_flash!(socket, :success, "Form is valid")
      {:noreply, assign(socket, %{form_valid: true})}
    else

      errors = myform.errors 
             |> Enum.map(fn { field, { message, _ }} -> {field, message} end)
             
      {:noreply,
        socket
        |> assign(%{form_valid: false})
        |> assign(%{errors: errors})
      }

    end
  end

  def handle_info({:put_flash, type, message}, _params, socket) do
    {:noreply, put_flash(socket, type, message)}
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
    form_animals
    |> Enum.map(fn id -> id |> String.to_integer end )
    |> Enum.map(fn x -> Enum.reduce(animal_collection, [], fn y, acc -> if x == y.id, do: y, else: acc end) end) 
    |> Enum.map(fn animal -> animal |> Map.from_struct end )
  end

end
