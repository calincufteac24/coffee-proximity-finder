# frozen_string_literal: true

require "test_helper"

describe "NearbyCoffeeShopsResolver" do
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
        highlighted
      }
    }
  GQL

  let(:origin) { { latitude: 47.6062, longitude: -122.3321 } }

  before do
    create(:coffee_shop, name: "Closest Shop",  latitude: 47.6065, longitude: -122.3325)
    create(:coffee_shop, name: "Second Shop",   latitude: 47.6100, longitude: -122.3350)
    create(:coffee_shop, name: "Third Shop",    latitude: 47.6150, longitude: -122.3400)
    create(:coffee_shop, name: "Fourth Shop",   latitude: 47.6200, longitude: -122.3500)
  end

  describe "with valid coordinates" do
    it "orders results by distance" do
      distances = fetch_shops.map { |s| s["distance"] }
      assert_equal distances.sort, distances
    end

    it "returns id for each result" do
      fetch_shops.each { |shop| assert_not_nil shop["id"] }
    end

    it "returns name for each result" do
      fetch_shops.each { |shop| assert_not_nil shop["name"] }
    end

    it "returns latitude for each result" do
      fetch_shops.each { |shop| assert_not_nil shop["latitude"] }
    end

    it "returns longitude for each result" do
      fetch_shops.each { |shop| assert_not_nil shop["longitude"] }
    end

    it "returns non-negative distance for each result" do
      fetch_shops.each { |shop| assert_operator shop["distance"], :>=, 0 }
    end

    it "highlights first 3 results" do
      fetch_shops.first(3).each { |shop| assert shop["highlighted"] }
    end

    it "does not highlight results beyond first 3" do
      fetch_shops.drop(3).each { |shop| refute shop["highlighted"] }
    end
  end

  describe "with invalid coordinates" do
    it "returns error for invalid latitude" do
      result = execute_query(latitude: 91.0, longitude: 0.0)
      assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
    end

    it "returns error for invalid longitude" do
      result = execute_query(latitude: 0.0, longitude: 181.0)
      assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
    end

    it "returns error for both invalid" do
      result = execute_query(latitude: 91.0, longitude: 181.0)
      assert_equal I18n.t("api.errors.invalid_coordinates.detail"), result.dig("errors", 0, "message")
    end
  end

  private

  def execute_query(latitude: origin[:latitude], longitude: origin[:longitude])
    CoffeeProximityFinderSchema.execute(
      QUERY,
      variables: { latitude: latitude, longitude: longitude }
    ).to_h
  end

  def fetch_shops
    result = execute_query
    result.dig("data", "nearbyCoffeeShops")
  end
end
