defmodule FbBot3Web.WebhookController do
use FbBot3Web, :controller

  def challenge(conn, params) do
    challenge = params["hub.challenge"] && params["hub.challenge"] |> String.to_integer()
    IO.inspect(conn)
    IO.inspect(params)
    IO.inspect("hereeee")
    json(conn, challenge)
  end

  def message_events(conn, params) do
    IO.inspect(conn)
    IO.inspect(params)
    json(conn, 123)
  end
end
