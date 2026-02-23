# frozen_string_literal: true

require "test_helper"

class CoffeeShopTest < ActiveSupport::TestCase
  setup do
    @shop = coffee_shops(:starbucks_seattle)
  end

  test "is valid with all required attributes" do
    assert @shop.valid?
  end

  test "is invalid without a name" do
    @shop.name = nil
    assert_not @shop.valid?
    assert_includes @shop.errors[:name], "can't be blank"
  end

  test "is invalid without a latitude" do
    @shop.latitude = nil
    assert_not @shop.valid?
    assert_includes @shop.errors[:latitude], "can't be blank"
  end

  test "is invalid without a longitude" do
    @shop.longitude = nil
    assert_not @shop.valid?
    assert_includes @shop.errors[:longitude], "can't be blank"
  end

  test "is invalid when latitude is below -90" do
    @shop.latitude = -90.1
    assert_not @shop.valid?
    assert_includes @shop.errors[:latitude], "must be greater than or equal to -90"
  end

  test "is invalid when latitude is above 90" do
    @shop.latitude = 90.1
    assert_not @shop.valid?
    assert_includes @shop.errors[:latitude], "must be less than or equal to 90"
  end

  test "is valid at latitude boundary -90" do
    @shop.latitude = -90
    assert @shop.valid?
  end

  test "is valid at latitude boundary 90" do
    @shop.latitude = 90
    assert @shop.valid?
  end

  test "is invalid when longitude is below -180" do
    @shop.longitude = -180.1
    assert_not @shop.valid?
    assert_includes @shop.errors[:longitude], "must be greater than or equal to -180"
  end

  test "is invalid when longitude is above 180" do
    @shop.longitude = 180.1
    assert_not @shop.valid?
    assert_includes @shop.errors[:longitude], "must be less than or equal to 180"
  end

  test "is valid at longitude boundary -180" do
    @shop.longitude = -180
    assert @shop.valid?
  end

  test "is valid at longitude boundary 180" do
    @shop.longitude = 180
    assert @shop.valid?
  end

  test "is invalid with a duplicate external_id" do
    duplicate = CoffeeShop.new(
      name: "Different Name",
      latitude: 0.0,
      longitude: 0.0,
      external_id: @shop.external_id
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "has already been taken"
  end

  test "auto-generates external_id before validation when blank" do
    shop = CoffeeShop.new(name: "Test Shop", latitude: 40.0, longitude: -74.0)
    assert_nil shop.external_id

    shop.valid?

    assert_not_nil shop.external_id
    expected = Digest::SHA256.hexdigest("Test Shop|40.0|-74.0")
    assert_equal expected, shop.external_id
  end

  test "does not overwrite an existing external_id" do
    original_id = @shop.external_id
    @shop.valid?
    assert_equal original_id, @shop.external_id
  end

  test ".generate_external_id produces a deterministic SHA256 digest" do
    result = CoffeeShop.generate_external_id(
      name: "Starbucks Seattle",
      latitude: 47.5809,
      longitude: -122.316
    )

    expected = Digest::SHA256.hexdigest("Starbucks Seattle|47.5809|-122.316")
    assert_equal expected, result
  end

  test ".generate_external_id produces different digests for different inputs" do
    id_a = CoffeeShop.generate_external_id(name: "A", latitude: 1.0, longitude: 2.0)
    id_b = CoffeeShop.generate_external_id(name: "B", latitude: 1.0, longitude: 2.0)

    assert_not_equal id_a, id_b
  end

  # Address validations

  test "is valid with a blank address" do
    @shop.address = ""
    assert @shop.valid?
  end

  test "is valid with a nil address" do
    @shop.address = nil
    assert @shop.valid?
  end

  test "is invalid when address exceeds max length" do
    @shop.address = "a" * (CoffeeShop::MAX_ADDRESS_LENGTH + 1)
    assert_not @shop.valid?
    assert_includes @shop.errors[:address], "is too long (maximum is #{CoffeeShop::MAX_ADDRESS_LENGTH} characters)"
  end

  test "is valid at address max length boundary" do
    @shop.address = "a" * CoffeeShop::MAX_ADDRESS_LENGTH
    assert @shop.valid?
  end

  # Schedule validations

  test "is valid with a blank schedule" do
    @shop.schedule = ""
    assert @shop.valid?
  end

  test "is valid with a nil schedule" do
    @shop.schedule = nil
    assert @shop.valid?
  end

  test "is invalid when schedule exceeds max length" do
    @shop.schedule = "a" * (CoffeeShop::MAX_SCHEDULE_LENGTH + 1)
    assert_not @shop.valid?
    assert_includes @shop.errors[:schedule], "is too long (maximum is #{CoffeeShop::MAX_SCHEDULE_LENGTH} characters)"
  end

  test "is valid at schedule max length boundary" do
    @shop.schedule = "a" * CoffeeShop::MAX_SCHEDULE_LENGTH
    assert @shop.valid?
  end
end
