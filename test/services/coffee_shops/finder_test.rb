# frozen_string_literal: true

require "test_helper"

class CoffeeShops::FinderTest < ActiveSupport::TestCase
  setup do
    @seattle = coffee_shops(:starbucks_seattle)
    @seattle2 = coffee_shops(:starbucks_seattle2)
    @sf = coffee_shops(:starbucks_sf)
  end

  test "returns the 3 closest shops sorted by distance" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    assert_equal 3, results.size
    assert results[0].distance <= results[1].distance
    assert results[1].distance <= results[2].distance
  end

  test "returns Result value objects" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    results.each do |result|
      assert_instance_of CoffeeShops::Finder::Result, result
      assert_instance_of CoffeeShop, result.coffee_shop
      assert_respond_to result, :distance
    end
  end

  test "closest shop to Seattle coordinates is a Seattle shop" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    closest_name = results.first.coffee_shop.name
    assert_includes closest_name, "Seattle"
  end

  test "SF shop is furthest from Seattle coordinates" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    furthest = results.last.coffee_shop
    assert_equal "Starbucks SF", furthest.name
  end

  test "respects the limit parameter" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4", limit: 1).call

    assert_equal 1, results.size
  end

  test "returns all shops when limit exceeds total count" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4", limit: 100).call

    assert_equal CoffeeShop.count, results.size
  end

  test "distances are positive numbers" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    results.each do |result|
      assert_operator result.distance.to_f, :>, 0
    end
  end

  test "distance to same coordinates is zero" do
    shop = @seattle
    results = CoffeeShops::Finder.new(
      latitude: shop.latitude.to_s,
      longitude: shop.longitude.to_s,
      limit: 1
    ).call

    assert_in_delta 0.0, results.first.distance.to_f, 0.001
  end

  test "respects custom scope" do
    scope = CoffeeShop.where(name: "Starbucks SF")
    results = CoffeeShops::Finder.new(
      latitude: "47.6", longitude: "-122.4", scope: scope
    ).call

    assert_equal 1, results.size
    assert_equal "Starbucks SF", results.first.coffee_shop.name
  end

  test "handles string coordinates from params" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    assert_not_empty results
  end

  test "handles numeric coordinates" do
    results = CoffeeShops::Finder.new(latitude: 47.6, longitude: -122.4).call

    assert_not_empty results
  end

  test "returns empty array when no shops in database" do
    CoffeeShop.delete_all
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    assert_equal [], results
  end

  test "Result value objects are immutable" do
    results = CoffeeShops::Finder.new(latitude: "47.6", longitude: "-122.4").call

    assert results.first.frozen?
  end
end
