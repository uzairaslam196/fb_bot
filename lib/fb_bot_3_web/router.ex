defmodule FbBot3Web.Router do
  use FbBot3Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FbBot3Web do
    pipe_through :api

    get "/webhook", WebhookController, :challenge
    post "/webhook", WebhookController, :message_events
  end
end
