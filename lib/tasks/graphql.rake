# frozen_string_literal: true

namespace :graphql do
  desc "Dump GraphQL schema to SDL file"
  task dump_schema: :environment do
    schema = CoffeeProximityFinderSchema.to_definition
    schema_path = Rails.root.join("schema.graphql")
    File.write(schema_path, schema)
    puts "Schema dumped to #{schema_path}"
  end
end
