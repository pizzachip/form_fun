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
        <.input field={@form[:name]} label="Name" placeholder="Your full name" />
        <.input field={@form[:age]} type="number" min="0" max="120" placeholder="18" label="Age" />
          <label for="form_fields_animals" class="block text-sm font-semibold leading-6 text-zinc-800">Animals</label>
            <%= for animal <- @animals do %>
              <div class="flex items-center justify-between">
                <.input name={"form_fields[animals]["<>animal.id<>"][animal_id]"} type="hidden" value={animal.id} /> 
                <.input name={"form_fields[animals]["<>animal.id<>"][name]"} type="hidden" value={animal.name} /> 
                <.input name={"form_fields[animals]["<>animal.id<>"][chosen]"} type="checkbox" value={animal.chosen} checked={animal.chosen} label={animal.name} class="w-1/3" />
                <.input name={"form_fields[animals]["<>animal.id<>"][qty]"} value={animal.qty}  type="number" class="w-2/3" />  
              </div>
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
  def handle_event("save", %{"form_fields" => params}, socket) do
    animals = translate_animals(params["animals"]) 

    active_animals =
      animals
      |> Enum.filter(fn animal -> animal["chosen"] == "true" end)

    new_params = %{params | "animals" => active_animals }
    use_params = FormFields.changeset(%FormFields{}, new_params)
      
    {:noreply, 
      socket
      |> assign(:last_input, use_params |> apply_changes) 
      |> assign(:form, use_params |> to_form)
    }
  end

  @impl true
  def handle_event("validate", %{"form_fields" => params}, socket) do
    animals = translate_animals(params["animals"])

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
      acc -> [%Animal{id: to_string(length(acc) + 1), name: animal, qty: 0, chosen: false} | acc]
    end
  end

  @spec translate_animals(map()) :: [map()] 
  def translate_animals(form_animals) do
    form_animals
    |> Enum.to_list
    |> Enum.map(fn {_id, animap} -> animap end)
  end

end
