defmodule ReactChatWeb.RoomChannel do
  use ReactChatWeb, :channel
  alias ExAws.Dynamo
  alias ExAws.Dynamo.Decoder
  alias ReactChatWeb.Presence
  require Logger

  def join(_topic, %{"user_name" => user_name}, socket) do
    send(self(), {:after_join, user_name})
    {:ok, socket}
  end

  def handle_in("new_msg", %{"msg" => msg}, socket) do
    user_name = socket.assigns[:user_name]

    _ = put_message!(user_name, msg)

    broadcast(socket, "new_msg", %{msg: msg, user_name: user_name})
    {:reply, :ok, socket}
  end

  def handle_info({:after_join, user_name}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    msg_list = get_messages!()
    push(socket, "at_first", %{"msg_list" => msg_list})

    {:ok, _ref} = Presence.track(socket, user_name, %{online_at: now()})
    {:noreply, assign(socket, :user_name, user_name)}
  end

  def terminate(_reason, socket) do
    {:noreply, socket}
  end

  defp now do
    System.system_time(:second)
  end

  defp get_table_name! do
    Application.get_env(:react_chat, ReactChatWeb.RoomChannel)[:table_name]
  end

  defp get_messages! do
    search_conditions = [
      limit: 10,
      scan_index_forward: false,
      expression_attribute_values: %{channel_name: "react-chat"},
      key_condition_expression: "channel_name = :channel_name"
    ]

    get_table_name!()
    |> Dynamo.query(search_conditions)
    |> ExAws.request!()
    |> Map.fetch!("Items")
    |> Enum.map(fn item ->
      item
      |> Decoder.decode()
      |> Map.delete("channel_name")
      |> Map.delete("message_id")
    end)
  end

  defp put_message!(user_name, message_content) do
    Logger.info("user_name = #{user_name}")
    Logger.info("message_content = #{message_content}")

    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    id = "#{now}|#{user_name}"

    Logger.info("id = #{id}")

    item = %{
      "channel_name" => "react-chat",
      "message_id" => id,
      "user_name" => user_name,
      "msg" => message_content
    }

    Logger.info("item = #{inspect(item)}")

    case get_table_name!()
         |> Dynamo.put_item(item)
         |> ExAws.request() do
      {:ok, result} ->
        result

      error ->
        raise ExAws.Error, """
        ExAws Request Error!

        #{inspect(error)}
        """
    end
  end
end
