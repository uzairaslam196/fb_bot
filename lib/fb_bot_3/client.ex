defmodule FbBot3.Client do

  def build() do
    headers = [{"Content-Type", "application/json"}]

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end

  def build_coingecko() do
    headers = [{"Content-Type", "application/json"}]

    middleware = [
      {Tesla.Middleware.BaseUrl, coingicko_base_url()},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end

  def response(response) do
    case response do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, %{data: body, status: 200}}

      {_, %Tesla.Env{body: body, status: status}} ->
        {:error, %{message: body, status: status}}
    end
  end

  defp base_url(), do: "https://graph.facebook.com/v2.6"
  defp coingicko_base_url(), do: "https://api.coingecko.com/api/v3"
end
