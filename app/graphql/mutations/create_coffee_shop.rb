# frozen_string_literal: true

module Mutations
  class CreateCoffeeShop < Mutations::BaseMutation
    description "Create a new coffee shop"

    argument :name, String, required: true, description: "Name of the coffee shop"
    argument :latitude, Float, required: true, description: "Latitude coordinate"
    argument :longitude, Float, required: true, description: "Longitude coordinate"
    argument :address, String, required: false, description: "Street address"
    argument :schedule, String, required: false, description: "Opening hours"

    field :coffee_shop, Types::CoffeeShops::CoffeeShop, null: true, description: "The created coffee shop"
    field :errors, [ String ], null: false, description: "Validation errors"

    def resolve(**attributes)
      coffee_shop = CoffeeShop.new(attributes)

      if coffee_shop.save
        { coffee_shop: coffee_shop, errors: [] }
      else
        { coffee_shop: nil, errors: coffee_shop.errors.full_messages }
      end
    end
  end
end
