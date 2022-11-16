defmodule Challenge do
  @moduledoc """
  Service for get products and calculate the final price
  """

  @products_path "#{File.cwd!()}/products.json"

  def execute([]), do: {:error, "no scanned items"}

  def execute(scanned_products, pricing_rules) do
    with {:ok, products} <- get_products_from_json() do
      result =
        scanned_products
        |> validate_scanned_items(products)
        |> calculate_price_of_every_product(products, [])
        |> apply_promotion(pricing_rules)
        |> calculate_final_purchase()

      {:ok, result}
    end
  end

  def get_products_from_json() do
    with {:ok, body} <- File.read(@products_path),
         {:ok, json} <- Poison.decode(body) do
      {:ok, json}
    else
      _ -> {:error, "Error in trying to read the products.json"}
    end
  end

  def validate_scanned_items(scanned_products, products) do
    products_codes = Enum.map(products, & &1["code"])

    Enum.reduce(scanned_products, [], fn scanned_product, acc ->
      case scanned_product in products_codes do
        true -> acc ++ [scanned_product]
        false -> acc
      end
    end)
  end

  def calculate_price_of_every_product([], _products, acc), do: acc

  def calculate_price_of_every_product(
        [scanned_item | _tail] = valid_scanned_items,
        products,
        acc
      ) do
    quantity = Enum.count(valid_scanned_items, &(&1 == scanned_item))
    product = Enum.find(products, &(&1["code"] == scanned_item))

    final_price = product["price"] * quantity

    mapped_product = %{
      quantity: quantity,
      final_price: final_price,
      price: product["price"],
      code: product["code"],
      name: product["name"],
      discount_code: product["discount_code"]
    }

    filtered_scanned_items = Enum.filter(valid_scanned_items, &(&1 != scanned_item))

    calculate_price_of_every_product(filtered_scanned_items, products, acc ++ [mapped_product])
  end

  def apply_promotion(products, []), do: products

  def apply_promotion(products, pricing_rules),
    do: Enum.map(products, &apply_promotion_by_discount_code(&1, pricing_rules))

  def apply_promotion_by_discount_code(%{discount_code: nil} = product, _pricing_rules),
    do: product

  def apply_promotion_by_discount_code(%{discount_code: 1} = product, pricing_rules)
      when product.quantity >= 2 do
    discount_percentage = 100
    quantity_of_activated_promotions = Float.floor(product.quantity / 2)

    discount =
      calculate_discount(discount_percentage, product.price) * quantity_of_activated_promotions

    new_price = product.final_price - discount

    if product.discount_code in pricing_rules do
      Map.put(product, :final_price, new_price)
    else
      product
    end
  end

  def apply_promotion_by_discount_code(%{discount_code: 1} = product, _pricing_rules), do: product

  def apply_promotion_by_discount_code(%{discount_code: 2} = product, pricing_rules)
      when product.quantity >= 3 do
    discount_percentage = 5
    discount = calculate_discount(discount_percentage, product.price)

    price_with_discount = product.price - discount
    new_price = price_with_discount * product.quantity

    if product.discount_code in pricing_rules do
      Map.put(product, :final_price, new_price)
    else
      product
    end
  end

  def apply_promotion_by_discount_code(%{discount_code: 2} = product, _pricing_rules), do: product

  def calculate_discount(discount_percentade, price), do: discount_percentade * price / 100

  def calculate_final_purchase(products) do
    final_purchase =
      Enum.reduce(products, 0, fn product, acc ->
        acc + product.final_price
      end)

    %{products: products, total: final_purchase}
  end
end
