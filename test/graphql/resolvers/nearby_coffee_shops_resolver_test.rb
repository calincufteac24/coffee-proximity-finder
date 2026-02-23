# frozen_string_literal: true

require "test_helper"

class NearbyCoffeeShopsResolverTest < ActiveSupport::TestCase
  QUERY = <<~GQL
    query($latitude: Float!, $longitude: Float!) {
      nearbyCoffeeShops(latitude: $latitude, longitude: $longitude) {
        coffeeShop {
          id
          name
          latitude
          longitude
          address
          schedule
        }
        distance
      }
    }
  GQL

  setup do
    @seattle = coffee_shops(:starbucks_seattle)
    @seattle2 = coffee_shops(:starbucks_seattle2)
    @sf = coffee_shops(:starbucks_sf)
  end

  test "returns coffee shops ordered by distance" do
    result = execute_query(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    shops = result.dig("data", "nearbyCoffeeShops")
    assert_not_nil shops
    assert shops.length <= 3

    distances = shops.map { |s| s["distance"] }
    assert_equal distances, distances.sort
  end

  test "returns all fields for each coffee shop" do
    result = execute_query(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    first = result.dig("data", "nearbyCoffeeShops", 0, "coffeeShop")
    assert_not_nil first["id"]
    assert_not_nil first["name"]
    assert_not_nil first["latitude"]
    assert_not_nil first["longitude"]
  end

  test "returns distance for each result" do
    result = execute_query(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    result.dig("data", "nearbyCoffeeShops").each do |shop_result|
      assert shop_result["distance"].is_a?(Numeric)
      assert shop_result["distance"] >= 0
    end
  end

  test "returns error for invalid latitude" do
    result = execute_query(latitude: 91.0, longitude: 0.0)

    errors = result["errors"]
    assert_not_nil errors
    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), errors.first["message"]
  end

  test "returns error for invalid longitude" do
    result = execute_query(latitude: 0.0, longitude: 181.0)

    errors = result["errors"]
    assert_not_nil errors
    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), errors.first["message"]
  end

  test "returns errors for both invalid coordinates" do
    result = execute_query(latitude: 91.0, longitude: 181.0)

    error_message = result.dig("errors", 0, "message")
    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), error_message
  end

  private

  def execute_query(latitude:, longitude:)
    CoffeeProximityFinderSchema.execute(
      QUERY,
      variables: { latitude: latitude, longitude: longitude }
    ).to_h
  end
end
