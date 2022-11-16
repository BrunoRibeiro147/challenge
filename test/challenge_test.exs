defmodule ChallengeTest do
  use ExUnit.Case

  describe "execute" do
    setup do
      params = ["VOUCHER", "VOUCHER", "TSHIRT", "TSHIRT", "TSHIRT", "MUG"]

      pricing_rules = [1, 2]

      %{params: params, pricing_rules: pricing_rules}
    end

    test "should calculate final price of products", %{
      params: params,
      pricing_rules: pricing_rules
    } do
      assert {:ok,
              %{
                products: [
                  %{
                    code: "VOUCHER",
                    discount_code: 1,
                    final_price: 5.0,
                    name: "Voucher",
                    price: 5.0,
                    quantity: 2
                  },
                  %{
                    code: "TSHIRT",
                    discount_code: 2,
                    final_price: 57.0,
                    name: "T-Shirt",
                    price: 20.0,
                    quantity: 3
                  },
                  %{
                    code: "MUG",
                    discount_code: nil,
                    final_price: 7.5,
                    name: "Coffee Mug",
                    price: 7.5,
                    quantity: 1
                  }
                ],
                total: 69.5
              }} = Challenge.execute(params, pricing_rules)
    end

    test "should not apply discount to a product when the pricing_rule was not passed", %{
      params: params
    } do
      assert {:ok,
              %{
                products: [
                  %{
                    code: "VOUCHER",
                    discount_code: 1,
                    final_price: 5.0,
                    name: "Voucher",
                    price: 5.0,
                    quantity: 2
                  },
                  %{
                    code: "TSHIRT",
                    discount_code: 2,
                    final_price: 60.0,
                    name: "T-Shirt",
                    price: 20.0,
                    quantity: 3
                  },
                  %{
                    code: "MUG",
                    discount_code: nil,
                    final_price: 7.5,
                    name: "Coffee Mug",
                    price: 7.5,
                    quantity: 1
                  }
                ],
                total: 72.5
              }} =
               Challenge.execute(params, [1])
    end

    test "should return an error if no scanned items was passed" do
      assert {:error, "no scanned items"} = Challenge.execute([])
    end
  end
end
