# frozen_string_literal: true

module Resolvers
  class NearbyCoffeeShopsResolver < Resolvers::BaseResolver
    description "Find coffee shops closest to the given coordinates"

    type [Types::CoffeeShopResultType], null: false

    argument :latitude, Float, required: true, description: "Latitude of the search origin"
    argument :longitude, Float, required: true, description: "Longitude of the search origin"

    def resolve(latitude:, longitude:)
      validate_coordinates!(latitude, longitude)

      CoffeeShops::Finder.new(latitude: latitude, longitude: longitude).call
    end

    private

    def validate_coordinates!(latitude, longitude)
      return if CoordinateValidator.valid?(latitude, longitude)

      raise GraphQL::ExecutionError, I18n.t("api.errors.invalid_coordinates.detail")
    end
  end
end
