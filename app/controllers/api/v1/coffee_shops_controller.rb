module Api
  module V1
    class CoffeeShopsController < Api::V1::BaseController
      def index
        return render_coordinate_errors unless valid_coordinates?

        results = find_closest_shops
        render json: serialize_results(results), status: :ok
      end

      private

      def find_closest_shops
        CoffeeShops::Finder.new(latitude: params[:x], longitude: params[:y]).call
      end

      def serialize_results(results)
        CoffeeShopSerializer.serialize_search_results(results, latitude: params[:x], longitude: params[:y])
      end

      def valid_coordinates?
        CoordinateValidator.valid_latitude?(params[:x]) && CoordinateValidator.valid_longitude?(params[:y])
      end

      def render_coordinate_errors
        render_jsonapi_errors(
          [ {
            status: "422",
            title: I18n.t("api.errors.invalid_coordinates.title"),
            detail: I18n.t("api.errors.invalid_coordinates.detail")
          } ],
          status: :unprocessable_entity
        )
      end
    end
  end
end
