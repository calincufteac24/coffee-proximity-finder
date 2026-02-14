module Api
  module V1
    class CoffeeShopsController < Api::V1::BaseController
      def index
        # TODO: Implement proximity search logic
        render json: { data: [], message: "Proximity search coming soon" }
      end
    end
  end
end
