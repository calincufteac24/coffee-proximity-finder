module Api
  module V1
    class CoffeeShopsController < Api::V1::BaseController
      def index
        return render_coordinate_errors unless valid_coordinates?

        @results = find_closest_shops
        render json: serialize_results, status: :ok
      end

      private

      def find_closest_shops
        CoffeeShopFinder.new(x: params[:x], y: params[:y], limit: 3).call
      end

      def serialize_results
        CoffeeShopSerializer.format_collection(@results, origin_x: params[:x], origin_y: params[:y])
      end

      def valid_coordinates?
        DataValidator.valid_latitude?(params[:x]) && DataValidator.valid_longitude?(params[:y])
      end

      def render_coordinate_errors
        render_jsonapi_errors(
          [{
            status: "422",
            title: I18n.t("api.errors.invalid_coordinates.title"),
            detail: I18n.t("api.errors.invalid_coordinates.detail")
          }],
          status: :unprocessable_entity
        )
      end
    end
  end
end
