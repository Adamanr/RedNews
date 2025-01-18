defmodule Rednews.Repo do
  use Ecto.Repo,
    otp_app: :rednews,
    adapter: Ecto.Adapters.Postgres
end
