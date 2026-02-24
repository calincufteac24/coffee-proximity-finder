# frozen_string_literal: true

class CoffeeProximityFinderSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Dataloader

  max_query_string_tokens(5000)
  validate_max_errors(100)
end
