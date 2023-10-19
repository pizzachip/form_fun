defmodule FormFun.Repo do
  use Ecto.Repo,
    otp_app: :form_fun,
    adapter: Ecto.Adapters.Postgres
end
