defmodule Checkout do
  @moduledoc """
  Simple interface for Checkout
  """

  def new(pricing_rules \\ []) do
    start_link(pricing_rules)

    __MODULE__
  end

  defp start_link(pricing_rules) do
    Agent.start_link(fn -> %{scanned_items: [], pricing_rules: pricing_rules} end,
      name: __MODULE__
    )
  end

  def scan(item) do
    Agent.get_and_update(__MODULE__, fn state ->
      scanned_items = state.scanned_items
      new_state = Map.put(state, :scanned_items, scanned_items ++ [String.upcase(item)])

      {state, new_state}
    end)

    :ok
  end

  def total do
    scanned_items = Agent.get(__MODULE__, &Map.get(&1, :scanned_items))
    pricing_rules = Agent.get(__MODULE__, &Map.get(&1, :pricing_rules))

    {:ok, checkout} = Challenge.execute(scanned_items, pricing_rules)

    formatted_total = :erlang.float_to_binary(checkout.total, decimals: 2)

    "#{formatted_total}€"
  end
end
