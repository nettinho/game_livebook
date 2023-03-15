defmodule LivebookWeb.HealthController do
  use LivebookWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> json(%{
      "application" => "livebook"
    })
  end

  def node(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> text(Node.self())
  end
end
