defmodule FbBot3.MessagesTest do
  use ExUnit.Case, async: true

  alias FbBot3.Messages

  setup do
    recipient_id = Application.get_env(:fb_bot_3, :recipient_id)
    page_access_token = Application.get_env(:fb_bot_3, :page_access_token)
    if is_nil(recipient_id) or is_nil(page_access_token), do:
      raise "Please source env vars for recipient_id and page_access_token"

    [recipient_id: recipient_id]
  end

  describe "process responses for user" do
    test "with initial responses", %{recipient_id: recipient_id} do
      assert {:ok, response} = Messages.process(recipient_id)
      assert %{"message_id" => _, "recipient_id" => ^recipient_id} = response
    end

    test "if user wants to list coins", %{recipient_id: recipient_id} do
      assert {:ok, response} = Messages.process(%{"payload" => "yes"}, recipient_id)
      assert %{"message_id" => _, "recipient_id" => ^recipient_id} = response
    end

    test "if user doesn't want to list coins", %{recipient_id: recipient_id} do
      assert {:ok, response} = Messages.process(%{"payload" => "no"}, recipient_id)
      assert %{"message_id" => _, "recipient_id" => ^recipient_id} = response
    end

    test "if user wants to get prices of coins", %{recipient_id: recipient_id} do
      assert {:ok, response} = Messages.process(%{"payload" => "01coin", "title" => "Get Prices"}, recipient_id)
      assert %{"message_id" => _, "recipient_id" => ^recipient_id} = response
    end
  end

  describe "build_requests" do
    test "get user first name", %{recipient_id: recipient_id}  do
      assert {:ok, response} = Messages.build_request({:ok, %{}}, recipient_id, :fetch_user_info)
      assert %{"first_name" => _} = response
    end

    test "send welcome greetings to user", %{recipient_id: recipient_id}  do
      response =
        {:ok, %{}}
        |> Messages.build_request(recipient_id, :fetch_user_info)
        |> Messages.build_request(recipient_id, :send_greetings)

      assert {:ok, %{"message_id" => _, "recipient_id" => ^recipient_id}} = response
    end

    test "ask user to list the coins", %{recipient_id: recipient_id}  do
      response = Messages.build_request({:ok, %{}} , recipient_id, :ask_user_coins)
      assert {:ok, %{"message_id" => _, "recipient_id" => ^recipient_id}} = response
    end

    test "send list of coins to user", %{recipient_id: recipient_id}  do
      coins = coins()
      response = Messages.build_request({:ok, coins} , recipient_id, :send_coins)
      assert {:ok, %{"message_id" => _, "recipient_id" => ^recipient_id}} = response
    end

    test "send coin prices to user", %{recipient_id: recipient_id}  do
      response =
        "01coin"
        |> Messages.build_coingecko_request(:get_coin_prices, 0)
        |> Messages.build_request(recipient_id, :send_coin_prices)

      assert  {:ok, %{"message_id" => _, "recipient_id" => ^recipient_id}} = response
    end

    defp coins() do
      [
        %{
          "id" => "01coin",
          "symbol" => "zoc",
          "name" => "01coin"
        },
        %{
          "id" => "0-5x-long-algorand-token",
          "symbol" => "algohalf",
          "name" => "0.5X Long Algorand Token"
        },
        %{
          "id" => "0-5x-long-altcoin-index-token",
          "symbol" => "althalf",
          "name" => "0.5X Long Altcoin Index Token"
        },
        %{
          "id" => "0-5x-long-ascendex-token-token",
          "symbol" => "asdhalf",
          "name" => "0.5X Long AscendEx Token Token"
        },
        %{
          "id" => "0-5x-long-bitcoin-cash-token",
          "symbol" => "bchhalf",
          "name" => "0.5X Long Bitcoin Cash Token"
        }
      ]
    end
  end

  describe "coingecko APIs" do
    test "get list of coins" do
      response = Messages.build_coingecko_request(:get_coins, 0)
      assert {:ok, body} = response
      assert is_list(body)
      assert [%{"id" => _, "symbol" => _, "name" => _} | _ ] = body
    end

    test "get coin prices" do
      response = Messages.build_coingecko_request("01coin", :get_coin_prices, 0)
      assert {:ok, %{"prices" => prices}} = response
      assert is_list(prices)
    end
  end
end
