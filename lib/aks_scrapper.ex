defmodule AksScrapper do
  alias AksScrapper.ResultRow

  @endpoint_url "https://www.allkeyshop.com/blog/wp-admin/admin-ajax.php"

  @spec request_for_game(String.t(), pos_integer() | nil) :: Req.Request.t()
  defp request_for_game(game_query, page) do
    params = [
      action: "catalogue_query",
      "query[search]": game_query,
      "query[sort]": "popularity-desc",
      "query[category]": "pc-games-all",
      "query[currency]": "eur"
    ]

    params =
      case page do
        nil ->
          params

        page when is_integer(page) and page >= 1 ->
          [{:"query[page]", to_string(page)} | params]
      end

    Req.new(
      url: @endpoint_url,
      method: :get,
      params: params
    )
  end

  @spec fetch_lazy(%{optional(key) => value}, key, (-> missing)) ::
          {:ok, value} | {:error, missing}
        when key: var, value: var, missing: var
  defp fetch_lazy(map, key, fun) do
    case Map.fetch(map, key) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, fun.()}
    end
  end

  @spec query_game(String.t(), pos_integer()) :: {:error, any()} | {:ok, [ResultRow.t()]}
  def query_game(game_query, page \\ 1) do
    result =
      game_query
      |> request_for_game(page)
      |> Req.request()

    with {:ok, response} <- result,
         {:ok, decoded_response} <- Jason.decode(response.body),
         {:ok, raw_html} <-
           fetch_lazy(decoded_response, "results", fn -> "Missing key in response" end),
         {:ok, parsed_html} <- Floki.parse_fragment(raw_html) do
      {:ok, ResultRow.parse_result_rows(parsed_html)}
    end
  end
end
