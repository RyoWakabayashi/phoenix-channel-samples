defmodule SimplePingPongWeb.RoomChannel do
  use SimplePingPongWeb, :channel
  require Logger

  @impl true
  def join(topic, payload, socket) do
    Logger.info("*** topic = #{topic}")

    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", %{"error" => true}, socket) do
    {:reply, {:error, %{reason: "error flag for ping request is true"}}, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
