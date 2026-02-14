# frozen_string_literal: true

require "test_helper"

class CoordinateValidatorTest < ActiveSupport::TestCase
  # --- valid_latitude? ---

  test "accepts valid latitude as string" do
    assert CoordinateValidator.valid_latitude?("47.6")
  end

  test "accepts valid latitude as number" do
    assert CoordinateValidator.valid_latitude?(47.6)
  end

  test "accepts latitude at boundary -90" do
    assert CoordinateValidator.valid_latitude?("-90")
  end

  test "accepts latitude at boundary 90" do
    assert CoordinateValidator.valid_latitude?("90")
  end

  test "accepts latitude zero" do
    assert CoordinateValidator.valid_latitude?("0")
  end

  test "rejects latitude above 90" do
    assert_not CoordinateValidator.valid_latitude?("90.1")
  end

  test "rejects latitude below -90" do
    assert_not CoordinateValidator.valid_latitude?("-90.1")
  end

  test "rejects latitude with letters" do
    assert_not CoordinateValidator.valid_latitude?("47.6abc")
  end

  test "rejects latitude as empty string" do
    assert_not CoordinateValidator.valid_latitude?("")
  end

  test "rejects latitude as nil" do
    assert_not CoordinateValidator.valid_latitude?(nil)
  end

  test "rejects latitude with spaces" do
    assert_not CoordinateValidator.valid_latitude?("47 .6")
  end

  test "rejects latitude with special characters" do
    assert_not CoordinateValidator.valid_latitude?("47.6!@#")
  end

  # --- valid_longitude? ---

  test "accepts valid longitude as string" do
    assert CoordinateValidator.valid_longitude?("-122.4")
  end

  test "accepts longitude at boundary -180" do
    assert CoordinateValidator.valid_longitude?("-180")
  end

  test "accepts longitude at boundary 180" do
    assert CoordinateValidator.valid_longitude?("180")
  end

  test "rejects longitude above 180" do
    assert_not CoordinateValidator.valid_longitude?("180.1")
  end

  test "rejects longitude below -180" do
    assert_not CoordinateValidator.valid_longitude?("-180.1")
  end

  # --- valid? ---

  test "valid? accepts both valid coordinates" do
    assert CoordinateValidator.valid?(45.0, -122.0)
  end

  test "valid? rejects when latitude is invalid" do
    assert_not CoordinateValidator.valid?(999, -122.0)
  end

  test "valid? rejects when longitude is invalid" do
    assert_not CoordinateValidator.valid?(45.0, 999)
  end

  test "valid? rejects when both are invalid" do
    assert_not CoordinateValidator.valid?(999, 999)
  end

  # --- to_decimal ---

  test "to_decimal converts string to BigDecimal" do
    result = CoordinateValidator.to_decimal("47.5809")
    assert_instance_of BigDecimal, result
    assert_equal BigDecimal("47.5809"), result
  end

  test "to_decimal converts negative string" do
    result = CoordinateValidator.to_decimal("-122.316")
    assert_equal BigDecimal("-122.316"), result
  end

  test "to_decimal converts integer string" do
    result = CoordinateValidator.to_decimal("90")
    assert_equal BigDecimal("90"), result
  end

  test "to_decimal returns BigDecimal as-is" do
    bd = BigDecimal("47.5809")
    assert_same bd, CoordinateValidator.to_decimal(bd)
  end

  test "to_decimal returns nil for non-numeric input" do
    assert_nil CoordinateValidator.to_decimal("abc")
  end

  test "to_decimal returns nil for mixed input" do
    assert_nil CoordinateValidator.to_decimal("47.5abc")
  end

  test "to_decimal returns nil for empty string" do
    assert_nil CoordinateValidator.to_decimal("")
  end

  test "to_decimal returns nil for nil" do
    assert_nil CoordinateValidator.to_decimal(nil)
  end

  test "to_decimal rejects double dots" do
    assert_nil CoordinateValidator.to_decimal("47.58.09")
  end

  test "to_decimal rejects leading dot" do
    assert_nil CoordinateValidator.to_decimal(".5809")
  end
end
