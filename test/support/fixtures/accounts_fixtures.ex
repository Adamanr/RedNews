defmodule Rednews.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rednews.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Rednews.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a channels.
  """
  def channels_fixture(attrs \\ %{}) do
    {:ok, channels} =
      attrs
      |> Enum.into(%{
        additional: %{},
        category: ["option1", "option2"],
        desc: "some desc",
        header: "some header",
        is_verificated: true,
        links: "some links",
        logo: "some logo",
        name: "some name",
        stars: 42
      })
      |> Rednews.Accounts.create_channels()

    channels
  end
end
