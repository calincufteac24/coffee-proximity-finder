# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :health, String, null: false, description: "API health check"

    def health
      "ok"
    end
  end
end
