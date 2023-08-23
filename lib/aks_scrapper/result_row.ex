defmodule AksScrapper.ResultRow do
  @result_row ".search-results-row"
  @result_row_title ".search-results-row-game-title"
  @result_row_info ".search-results-row-game-infos"
  @result_row_price ".search-results-row-price"

  @enforce_keys [:title, :year, :category, :price]
  defstruct [:title, :year, :category, :price]

  @type t() :: %__MODULE__{
          title: String.t(),
          year: pos_integer(),
          category: String.t(),
          price: String.t()
        }

  @spec new(
          title :: String.t(),
          year :: pos_integer(),
          category :: String.t(),
          price :: String.t()
        ) :: t()
  def new(title, year, category, price) do
    %__MODULE__{title: title, year: year, category: category, price: price}
  end

  @spec parse_result_rows(Floki.html_tree()) :: [t()]
  def parse_result_rows(html) do
    html
    |> Floki.find(@result_row)
    |> Enum.map(&parse_result_row/1)
  end

  @spec parse_result_row(Floki.html_tree()) :: t()
  defp parse_result_row(html) do
    title = find_text_for_class(html, @result_row_title)
    info = find_text_for_class(html, @result_row_info)
    price = html |> find_text_for_class(@result_row_price) |> String.trim()

    [year, category] = String.split(info, "-") |> Enum.map(&String.trim/1)
    year = String.to_integer(year)

    new(title, year, category, price)
  end

  @spec find_text_for_class(Floki.html_tree(), String.t()) :: String.t()
  defp find_text_for_class(html, class) do
    [selection] = Floki.find(html, class)
    Floki.text(selection)
  end
end
