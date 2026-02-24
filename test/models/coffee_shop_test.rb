# frozen_string_literal: true

require "test_helper"

describe CoffeeShop do
  before do
    @shop = coffee_shops(:starbucks_seattle)
  end

  it "is valid with all required attributes" do
    assert @shop.valid?
  end

  describe "name" do
    it "is required" do
      @shop.name = nil
      assert_not @shop.valid?
      assert_includes @shop.errors[:name], "can't be blank"
    end
  end

  describe "latitude" do
    it "is required" do
      @shop.latitude = nil
      assert_not @shop.valid?
      assert_includes @shop.errors[:latitude], "can't be blank"
    end

    it "rejects values below -90" do
      @shop.latitude = -90.1
      assert_not @shop.valid?
      assert_includes @shop.errors[:latitude], "must be greater than or equal to -90"
    end

    it "rejects values above 90" do
      @shop.latitude = 90.1
      assert_not @shop.valid?
      assert_includes @shop.errors[:latitude], "must be less than or equal to 90"
    end

    it "accepts boundary -90" do
      @shop.latitude = -90
      assert @shop.valid?
    end

    it "accepts boundary 90" do
      @shop.latitude = 90
      assert @shop.valid?
    end
  end

  describe "longitude" do
    it "is required" do
      @shop.longitude = nil
      assert_not @shop.valid?
      assert_includes @shop.errors[:longitude], "can't be blank"
    end

    it "rejects values below -180" do
      @shop.longitude = -180.1
      assert_not @shop.valid?
      assert_includes @shop.errors[:longitude], "must be greater than or equal to -180"
    end

    it "rejects values above 180" do
      @shop.longitude = 180.1
      assert_not @shop.valid?
      assert_includes @shop.errors[:longitude], "must be less than or equal to 180"
    end

    it "accepts boundary -180" do
      @shop.longitude = -180
      assert @shop.valid?
    end

    it "accepts boundary 180" do
      @shop.longitude = 180
      assert @shop.valid?
    end
  end

  describe "address" do
    it "is valid when blank" do
      @shop.address = nil
      assert @shop.valid?
    end
  end

  describe "schedule" do
    it "is valid when blank" do
      @shop.schedule = nil
      assert @shop.valid?
    end
  end

  describe "external_id" do
    it "rejects duplicates" do
      duplicate = CoffeeShop.new(
        name: "Different Name",
        latitude: 0.0,
        longitude: 0.0,
        external_id: @shop.external_id
      )
      assert_not duplicate.valid?
      assert_includes duplicate.errors[:external_id], "has already been taken"
    end

    it "auto-generates when blank" do
      shop = CoffeeShop.new(name: "Test Shop", latitude: 40.0, longitude: -74.0)
      shop.valid?

      expected = Digest::SHA256.hexdigest("Test Shop|40.0|-74.0")
      assert_equal expected, shop.external_id
    end

    it "preserves existing value" do
      original_id = @shop.external_id
      @shop.valid?
      assert_equal original_id, @shop.external_id
    end
  end

  describe ".generate_external_id" do
    it "is deterministic" do
      result = CoffeeShop.generate_external_id(
        name: "Starbucks Seattle",
        latitude: 47.5809,
        longitude: -122.316
      )

      expected = Digest::SHA256.hexdigest("Starbucks Seattle|47.5809|-122.316")
      assert_equal expected, result
    end

    it "varies by input" do
      id_a = CoffeeShop.generate_external_id(name: "A", latitude: 1.0, longitude: 2.0)
      id_b = CoffeeShop.generate_external_id(name: "B", latitude: 1.0, longitude: 2.0)

      assert_not_equal id_a, id_b
    end
  end
end
