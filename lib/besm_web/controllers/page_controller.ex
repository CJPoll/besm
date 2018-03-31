defmodule BesmWeb.PageController do
  use BesmWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
