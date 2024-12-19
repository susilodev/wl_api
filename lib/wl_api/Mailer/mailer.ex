defmodule WlApi.Mailer.Mailer do
  use Swoosh.Mailer, otp_app: :wl_api

  def deliver_email(email) do
    deliver(email)
  end
end
