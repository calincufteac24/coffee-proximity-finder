# frozen_string_literal: true

module Types
  module CoffeeShops
    class CoffeeShop < Types::BaseObject
      description "A coffee shop with its location and details"

      field :id, ID, null: false, description: "Unique identifier"
      field :name, String, null: false, description: "Name of the coffee shop"
      field :latitude, Float, null: false, description: "Latitude coordinate"
      field :longitude, Float, null: false, description: "Longitude coordinate"
      field :address, String, description: "Street address"
      field :schedule, String, description: "Opening hours"
      field :distance, Float, description: "Distance from origin in km"
      field :highlighted, Boolean, description: "Whether this shop is in the top 3 closest"
    end
  end
end
