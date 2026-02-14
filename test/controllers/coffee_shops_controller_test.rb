# frozen_string_literal: true

require "test_helper"

class Api::V1::CoffeeShopsControllerTest < ActionDispatch::IntegrationTest
  # --- Happy path ---

  test "returns 200 with valid coordinates" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    assert_response :ok
  end

  test "returns JSON:API content type" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    assert_equal "application/vnd.api+json", response.content_type
  end

  test "returns data array with 3 results" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)
    assert_equal 3, json["data"].size
  end

  test "each result has correct JSON:API structure" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)
    result = json["data"].first

    assert result.key?("id")
    assert_equal "coffee_shop", result["type"]
    assert result["attributes"].key?("name")
    assert result["attributes"].key?("latitude")
    assert result["attributes"].key?("longitude")
    assert result["attributes"].key?("distance")
  end

  test "results are sorted by distance ascending" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)
    distances = json["data"].map { |d| d["attributes"]["distance"].to_f }

    assert_equal distances.sort, distances
  end

  test "meta contains origin coordinates" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)
    meta = json["meta"]

    assert_equal 47.6, meta["origin"]["latitude"]
    assert_equal(-122.4, meta["origin"]["longitude"])
  end

  test "meta contains total_count" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)

    assert_equal 3, json["meta"]["total_count"]
  end

  test "meta contains last_synced_at" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)

    assert json["meta"].key?("last_synced_at")
  end

  # --- Validation errors ---

  test "returns 422 when latitude is out of range" do
    get api_v1_coffee_shops_url, params: { x: "999", y: "-122.4" }

    assert_response :unprocessable_entity
  end

  test "returns 422 when longitude is out of range" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "999" }

    assert_response :unprocessable_entity
  end

  test "returns 422 when latitude is missing" do
    get api_v1_coffee_shops_url, params: { y: "-122.4" }

    assert_response :unprocessable_entity
  end

  test "returns 422 when longitude is missing" do
    get api_v1_coffee_shops_url, params: { x: "47.6" }

    assert_response :unprocessable_entity
  end

  test "returns 422 when both parameters are missing" do
    get api_v1_coffee_shops_url

    assert_response :unprocessable_entity
  end

  test "returns 422 when latitude contains letters" do
    get api_v1_coffee_shops_url, params: { x: "47.6abc", y: "-122.4" }

    assert_response :unprocessable_entity
  end

  test "returns 422 when longitude contains letters" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4asd" }

    assert_response :unprocessable_entity
  end

  test "error response follows JSON:API error format" do
    get api_v1_coffee_shops_url, params: { x: "999", y: "-122.4" }

    json = JSON.parse(response.body)
    error = json["errors"].first

    assert_equal "422", error["status"]
    assert error.key?("title")
    assert error.key?("detail")
  end

  test "error response has JSON:API content type" do
    get api_v1_coffee_shops_url, params: { x: "999", y: "-122.4" }

    assert_equal "application/vnd.api+json", response.content_type
  end

  # --- Edge cases ---

  test "returns 200 at latitude boundary 90" do
    get api_v1_coffee_shops_url, params: { x: "90", y: "0" }

    assert_response :ok
  end

  test "returns 200 at latitude boundary -90" do
    get api_v1_coffee_shops_url, params: { x: "-90", y: "0" }

    assert_response :ok
  end

  test "returns 200 at longitude boundary 180" do
    get api_v1_coffee_shops_url, params: { x: "0", y: "180" }

    assert_response :ok
  end

  test "returns 200 at longitude boundary -180" do
    get api_v1_coffee_shops_url, params: { x: "0", y: "-180" }

    assert_response :ok
  end

  test "returns 200 at origin coordinates 0,0" do
    get api_v1_coffee_shops_url, params: { x: "0", y: "0" }

    assert_response :ok
  end

  test "returns empty data array when no shops exist" do
    CoffeeShop.delete_all
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4" }

    json = JSON.parse(response.body)
    assert_equal [], json["data"]
    assert_equal 0, json["meta"]["total_count"]
  end

  # --- SQL injection attempt ---

  test "safely handles SQL injection in x parameter" do
    get api_v1_coffee_shops_url, params: { x: "47.6; DROP TABLE coffee_shops;--", y: "-122.4" }

    assert_response :unprocessable_entity
    assert CoffeeShop.count > 0, "Table should not have been dropped"
  end

  test "safely handles SQL injection in y parameter" do
    get api_v1_coffee_shops_url, params: { x: "47.6", y: "-122.4 OR 1=1" }

    assert_response :unprocessable_entity
  end
end
