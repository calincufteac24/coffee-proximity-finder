# frozen_string_literal: true

module Types
  class CoffeeShopResultType < Types::BaseObject
    description "A coffee shop with its distance from the search origin"

    field :coffee_shop, Types::CoffeeShopType, null: false, description: "The coffee shop"
    field :distance, Float, null: false, description: "Distance from origin in km"
  end
end
