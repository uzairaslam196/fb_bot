defmodule FbBot3.Messages do
  alias FbBot3.Client

  @moduledoc """
  This module handles all the facebook bot and coin_gecko APIs. All the APIs retries three times in case of failure.
  """

  @page_access_token Application.get_env(:fb_bot_3, :page_access_token)

  @doc """
  Accept recipient_id and process intial responses accordingly for a user
  """
  def process(recipient_id) do
    {:ok, %{}}
    |> build_request(recipient_id, :fetch_user_info)
    |> build_request(recipient_id, :send_greetings)
    |> build_request(recipient_id, :ask_user_coins)
  end

  @doc """
  Accept incoming event attributes with recipient_id and then process the responses accordingly
  """
  def process(%{"payload" => "yes"}, recipient_id) do
    :get_coins
    |> build_coingecko_request(0)
    |> build_request(recipient_id, :send_coins)
  end

  def process(%{"payload" => "no"}, recipient_id) do
    build_request("", recipient_id, :send_good_by)
  end

  def process(%{"payload" => id, "title" => "Get Prices"}, recipient_id) do
    id
    |> build_coingecko_request(:get_coin_prices, 0)
    |> build_request(recipient_id, :send_coin_prices)
  end

  @doc """
  Build and utilize facebook apis
  """
  def build_request(params, recipient_id, type, tries \\ 0)
  def build_request({:error, message}, _, _type, _),   do: {:error, message}
  def build_request(_params, _recipient_id, _type, 3), do: {:error, "error in request"}

  def build_request(params, recipient_id, :fetch_user_info, tries) do
    Client.build()
    |> Tesla.get("/#{recipient_id}?fields=first_name,last_name&access_token=#{@page_access_token}")
    |> IO.inspect()
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :fetch_user_info, tries + 1)
    end
  end

  def build_request({:ok, %{"first_name" => first_name}} = params, recipient_id, :send_greetings, tries) do
    elements =
      [
        %{
        title: "Welcome #{first_name}",
        image_url: "https://wallpaperaccess.com/full/3214373.jpg",
        subtitle: "In the world of cryptocurrencies 🤩"
        }
      ]

    body = build_body(recipient_id, elements)
    Client.build()
    |> Tesla.post("/me/messages?access_token=#{@page_access_token}", body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :send_greetings, tries + 1)
    end
  end

  def build_request(params, recipient_id, :ask_user_coins, tries) do
    elements =
      [
        %{
          title: "Want to list coins?",
          image_url: "https://cdn.corporatefinanceinstitute.com/assets/AdobeStock_132647999.jpeg",
          subtitle: "See the coins and their prices",
          buttons: [
            %{
              type: "postback",
              title: "Yes",
              payload: "yes"
            },
            %{
              type: "postback",
              title: "No",
              payload: "no"
             }
          ]
        }
      ]

    body = build_body(recipient_id, elements)
    Client.build()
    |> Tesla.post("/me/messages?access_token=#{@page_access_token}", body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :ask_user_coins, tries + 1)
    end
  end

  def build_request({:ok, coins} = params, recipient_id, :send_coins, tries) do
    elements = Enum.map(coins, &build_coin_elements/1)
    body     = build_body(recipient_id, elements)

    Client.build()
    |> Tesla.post("/me/messages?access_token=#{@page_access_token}", body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :send_coins, tries + 1)
    end
  end

  def build_request({:ok, %{"prices" => prices}} = params, recipient_id, :send_coin_prices, tries) do
    prices = Enum.reduce(prices, ~s(), fn [price | _], result -> result <> "- #{price} \n" end)
    text   = "Prices on previous 14 days: \n#{prices}"
    body   = buil_body_for_text(recipient_id, text)

    Client.build()
    |> Tesla.post("/me/messages?access_token=#{@page_access_token}", body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :send_coin_prices, tries + 1)
    end
  end

  def build_request(params, recipient_id, :send_good_by, tries) do
    text = "Hey !! No worries, just test me again whenever wish to list coins. \n We are here for you 😊"
    body = buil_body_for_text(recipient_id, text)

     Client.build()
     |> Tesla.post("/me/messages?access_token=#{@page_access_token}", body)
     |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{}} -> build_request(params, recipient_id, :send_good_by, tries + 1)
     end
  end

  # ------ fb apis helpers ------

  defp build_body(recipient_id, elements) do
    %{
      recipient: %{
        id: recipient_id
      },
      message: %{
        attachment: %{
          type: "template",
          payload: %{
            template_type: "generic",
            elements: elements
          }
        }
      }
    }
  end

  defp build_coin_elements(coin) do
    %{
      title: coin["name"],
      subtitle: "symbol: " <> coin["symbol"],
      buttons: [
        %{
          title: "Get Prices",
          type: "postback",
          payload: coin["id"]
        }
      ]
    }
  end

  defp buil_body_for_text(recipient_id, text_message) do
    %{
      messaging_type: "RESPONSE",
      recipient: %{
        id: recipient_id
      },
      message: %{
        text: text_message
      }
    }
  end

  @doc """
  Build and utilize coin_gecko apis
  """
  def build_coingecko_request(:get_coins, tries) do
    Client.build_coingecko()
    |> Tesla.get("/coins/list")
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, Enum.slice(body, 0..4)}
      {:ok, _} when tries < 3 -> build_coingecko_request(:get_coins, tries + 1)
      _ -> {:error, "error in coinginko request"}
    end
  end

  def build_coingecko_request(coin_id, :get_coin_prices, tries) do
    Client.build_coingecko()
    |> Tesla.get("/coins/#{coin_id}/market_chart?vs_currency=usd&days=14&interval=daily")
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, _} when tries < 3 -> build_coingecko_request(coin_id, :get_coin_prices, tries + 1)
      _ -> {:error, "error in coinginko request"}
    end
  end
end
