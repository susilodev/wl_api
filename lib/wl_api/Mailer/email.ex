defmodule WlApi.Mailer.Email do
  import Swoosh.Email

  def registration_confirmation(user, token) do
    confirmation_url = "http://localhost:4000/api/v1/auth/confirm-register?token=#{token}"

    new()
    |> to(user.email)
    |> from("no-reply@whitelist.com")
    |> subject("Confirm to Registration")
    |> html_body("""
    Hello #{user.username},<br>
    Please confirm your email by clicking <a href="#{confirmation_url}">here</a>.
    """)
    |> text_body("Hello #{user.username},\nPlease confirm your email by clicking the link below.")
  end
end
