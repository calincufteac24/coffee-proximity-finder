# frozen_string_literal: true

require "test_helper"

class NearbyCoffeeShopsResolverTest < ActiveSupport::TestCase
  QUERY = <<~GQL
    query($latitude: Float!, $longitude: Float!) {
      nearbyCoffeeShops(latitude: $latitude, longitude: $longitude) {
        id
        name
        latitude
        longitude
        address
        schedule
        distance
      }
    }
  GQL

  setup do
    @seattle = coffee_shops(:starbucks_seattle)
  end

  test "returns results ordered by distance" do
    shops = fetch_shops(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    distances = shops.map { |s| s["distance"] }
    assert_equal distances.sort, distances
  end

  test "returns id for each result" do
    shops = fetch_shops(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    shops.each { |shop| assert_not_nil shop["id"] }
  end

  test "returns name for each result" do
    shops = fetch_shops(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    shops.each { |shop| assert_not_nil shop["name"] }
  end

  test "returns coordinates for each result" do
    shops = fetch_shops(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    shops.each do |shop|
      assert_not_nil shop["latitude"]
      assert_not_nil shop["longitude"]
    end
  end

  test "returns non-negative distance for each result" do
    shops = fetch_shops(latitude: @seattle.latitude.to_f, longitude: @seattle.longitude.to_f)

    shops.each do |shop|
      assert_kind_of Numeric, shop["distance"]
      assert_operator shop["distance"], :>=, 0
    end
  end

  test "returns error for invalid latitude" do
    result = execute_query(latitude: 91.0, longitude: 0.0)

    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
  end

  test "returns error for invalid longitude" do
    result = execute_query(latitude: 0.0, longitude: 181.0)

    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
  end

  test "returns error for both invalid coordinates" do
    result = execute_query(latitude: 91.0, longitude: 181.0)

    assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
  end

  private

  def execute_query(latitude:, longitude:)
    CoffeeProximityFinderSchema.execute(
      QUERY,
      variables: { latitude: latitude, longitude: longitude }
    ).to_h
  end

  def fetch_shops(latitude:, longitude:)
    result = execute_query(latitude: latitude, longitude: longitude)
    result.dig("data", "nearbyCoffeeShops")
  end
end
