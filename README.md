# FbBot3

To start your Phoenix server:

* Please add env vars with PAGE_ACCESS_TOKEN, RECIPIENT_ID (who has permission to send messages via fb bot APIs)
  and VERIFICATION_ID (a key for callback URL) to .env file and run `source .env`

---- Or if you want to use your own fb application then please follow these instructions -----

* Or if you don't have env vars yet and want to use your own fb application then please go and create the fb 
  app following this link (https://developers.facebook.com/docs/development/create-an-app/)

* Once the application is created & setup permissions then get page_access_token, recipient_id(who have perission to use google apis)
  and add them in .env file as PAGE_ACCESS_TOKEN, RECIPIENT_ID.

* Add callback URL from there(current url is https://obscure-plains-02948.herokuapp.com/api/webhook or if you deploy this application on their on server separately then append this url /api/webhook with your base URL) with verification_key. You can use any string as verification key when adding callback url but make sure to add this VERIFICATION_KEY in .env file of project.

That's it.
---- end -----

* Install dependencies with `mix deps.get`
* iex -S mix phx.server

To run test cases

* mix test

Codebase metatdata

* test cases (test/fb_bot/messages_test.exs)
* webhook controller (lib/fb_bot_3_web/controllers/webhook_controller.ex)
* HTTP Client, fb_bot & coin_ginko APIs in following directory (lib/fb_bot_3)

Server URL: https://obscure-plains-02948.herokuapp.com/
Webhook URL: https://obscure-plains-02948.herokuapp.com/api/webhook

Note: (if you are facing issue with webhook events then please once put the webhook url in browser new tab to call server from there, it might be in sleep mode at heroku)
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
