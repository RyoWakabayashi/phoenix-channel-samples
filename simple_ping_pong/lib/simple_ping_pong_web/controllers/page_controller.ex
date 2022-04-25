defmodule SimplePingPongWeb.PageController do
  use SimplePingPongWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
