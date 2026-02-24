# frozen_string_literal: true

module Resolvers
  class NearbyCoffeeShopsResolver < Resolvers::BaseResolver
    description "Find coffee shops closest to the given coordinates"

    HIGHLIGHT_COUNT = 3

    type [ Types::CoffeeShops::CoffeeShop ], null: false

    argument :latitude, Float, required: true, description: "Latitude of the search origin"
    argument :longitude, Float, required: true, description: "Longitude of the search origin"
    argument :name, String, required: false, description: "Optional name filter"

    def resolve(latitude:, longitude:, name: nil)
      validate_coordinates!(latitude, longitude)

      find_nearby_shops(latitude, longitude, filter_by_name(name)).tap { |shops| apply_highlights(shops) }
    end

    private

    def filter_by_name(name)
      name.present? ? CoffeeShop.where("name ILIKE ?", "%#{name}%") : CoffeeShop.all
    end

    def find_nearby_shops(latitude, longitude, scope)
      CoffeeShops::Finder.new(latitude: latitude, longitude: longitude, scope: scope).call
                         .map(&:coffee_shop)
    end

    def apply_highlights(shops)
      shops.each_with_index { |shop, i| shop.highlighted = i < HIGHLIGHT_COUNT }
    end

    def validate_coordinates!(latitude, longitude)
      return if CoordinateValidator.valid?(latitude, longitude)

      raise GraphQL::ExecutionError, I18n.t("api.errors.invalid_coordinates.detail")
    end
  end
end
