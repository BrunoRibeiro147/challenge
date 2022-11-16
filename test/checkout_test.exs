defmodule CheckoutTest do
  use ExUnit.Case

  describe "checkout" do
    test "should start a agent" do
      Checkout.new()

      assert [] = Agent.get(Checkout, &Map.get(&1, :scanned_items))
    end

    test "should scan a item and saved" do
      co = Checkout.new()

      co.scan("voucher")

      assert ["VOUCHER"] = Agent.get(Checkout, &Map.get(&1, :scanned_items))
    end

    test "should calculate the total price of checkout" do
      co = Checkout.new()

      co.scan("voucher")
      co.scan("voucher")
      co.scan("tshirt")

      assert "30.00€" = co.total()
    end
  end
end
