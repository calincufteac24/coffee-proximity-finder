# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :nearby_coffee_shops, resolver: Resolvers::NearbyCoffeeShopsResolver
  end
end
