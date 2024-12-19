defmodule WlApiWeb.ErrorJSON do
  @moduledoc """
  Responsible for rendering JSON responses for errors.
  """

  # General error handler
  def render("500.json", _assigns) do
    %{error: "Internal server error"}
  end

  def render("404.json", _assigns) do
    %{error: "Resource not found"}
  end

  def render("400.json", _assigns) do
    %{error: "Bad request"}
  end

  def render("422.json", %{reason: reason}) do
    %{error: "Unprocessable entity", details: reason}
  end

  # Fallback for other statuses
  def render(template, _assigns) do
    %{
      error: Phoenix.Controller.status_message_from_template(template)
    }
  end
end
