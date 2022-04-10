# FbBot3

To start your Phoenix server:

* Please add env vars with PAGE_ACCESS_TOKEN, RECIPIENT_ID (who has permission to send messages via fb bot APIs)
  and VERIFICATION_ID (a key for callback URL)
  
* Or if you aready have these vars for development user then `source .env`
* Install dependencies with `mix deps.get`
* iex -S mix phx.server

To run test cases

* mix test

Codebase metatdata

* test cases (test/fb_bot/messages_test.exs)
* webhook controller (lib/fb_bot_3_web/controllers/webhook_controller.ex)
* HTTP Client, fb_bot & coin_ginko APIs in following directory (lib/fb_bot_3)

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
