# frozen_string_literal: true

require "test_helper"

describe "CreateCoffeeShop" do
  MUTATION = <<~GQL
    mutation($input: CreateCoffeeShopInput!) {
      createCoffeeShop(input: $input) {
        coffeeShop {
          id
          name
          latitude
          longitude
          address
          schedule
        }
        errors
      }
    }
  GQL

  describe "with valid attributes" do
    let(:input) do
      { name: "Test Coffee", latitude: 47.6062, longitude: -122.3321, address: "123 Main St", schedule: "Mon-Fri: 7-19" }
    end

    it "creates a coffee shop" do
      assert_difference "CoffeeShop.count", 1 do
        execute_mutation(input)
      end
    end

    it "returns the created coffee shop" do
      result = execute_mutation(input)
      coffee_shop = result.dig("data", "createCoffeeShop", "coffeeShop")

      assert_equal "Test Coffee", coffee_shop["name"]
      assert_equal 47.6062, coffee_shop["latitude"]
      assert_equal(-122.3321, coffee_shop["longitude"])
    end

    it "returns empty errors" do
      result = execute_mutation(input)
      errors = result.dig("data", "createCoffeeShop", "errors")

      assert_empty errors
    end

    it "auto-generates external_id" do
      execute_mutation(input)

      assert_not_nil CoffeeShop.last.external_id
    end
  end

  describe "with only required attributes" do
    let(:input) { { name: "Minimal Shop", latitude: 40.0, longitude: -74.0 } }

    it "creates a coffee shop without optional fields" do
      assert_difference "CoffeeShop.count", 1 do
        execute_mutation(input)
      end
    end
  end

  describe "with invalid attributes" do
    let(:input) { { name: "", latitude: 47.0, longitude: -122.0 } }

    it "returns validation errors for blank name" do
      result = execute_mutation(input)
      errors = result.dig("data", "createCoffeeShop", "errors")

      assert_includes errors, "Name can't be blank"
    end

    it "does not create a record" do
      assert_no_difference "CoffeeShop.count" do
        execute_mutation(input)
      end
    end

    it "returns null coffee shop on failure" do
      result = execute_mutation(input)

      assert_nil result.dig("data", "createCoffeeShop", "coffeeShop")
    end
  end

  describe "with invalid coordinates" do
    it "returns errors for latitude out of range" do
      result = execute_mutation(name: "Bad Shop", latitude: 91.0, longitude: 0.0)
      errors = result.dig("data", "createCoffeeShop", "errors")

      assert errors.any? { |e| e.include?("Latitude") }
    end

    it "returns errors for longitude out of range" do
      result = execute_mutation(name: "Bad Shop", latitude: 0.0, longitude: 181.0)
      errors = result.dig("data", "createCoffeeShop", "errors")

      assert errors.any? { |e| e.include?("Longitude") }
    end
  end

  private

  def execute_mutation(input = {})
    CoffeeProximityFinderSchema.execute(
      MUTATION,
      variables: { input: input }
    ).to_h
  end
end
