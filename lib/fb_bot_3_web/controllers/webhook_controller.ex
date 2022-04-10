defmodule FbBot3Web.WebhookController do
  use FbBot3Web, :controller
  require Logger

  @verification_key Application.get_env(:fb_bot_3, :verification_key)

  def challenge(conn, params) do
    IO.inspect(conn)
    IO.inspect("params")
    IO.inspect(params)
    if params["hub.verify_token"] == @verification_key do
      challenge = params["hub.challenge"] && String.to_integer(params["hub.challenge"])
      json(conn, challenge)
    else
      json(conn, nil)
    end
  end

  def message_events(conn, params) do
    FbBot3.Messages.process(params)
    [%{"messaging" => [message | _]} | _] = params["entry"]

    case do_message_events(message) do
      {:ok, _} ->
        Logger.info("Successfully sent the message's response")
        json(conn, "Successfully sent")

      {:error, message} ->
        Logger.error(message)
        json(conn, message)
    end
  end

  defp do_message_events(%{"message" => _message, "recipient" => %{"id" => id}}) do
    FbBot3.Messages.process(id)
  end

  defp do_message_events(%{"postback" => postback, "recipient" => %{"id" => id}}) do
    FbBot3.Messages.process(postback, id)
  end

  defp do_message_events(_), do: nil
end
