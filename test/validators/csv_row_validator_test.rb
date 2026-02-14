# frozen_string_literal: true

require "test_helper"

class CsvRowValidatorTest < ActiveSupport::TestCase
  # --- valid_structure? ---

  test "accepts array with exactly 3 columns" do
    assert CsvRowValidator.valid_structure?(%w[name 1.0 2.0])
  end

  test "rejects array with 2 columns" do
    assert_not CsvRowValidator.valid_structure?(%w[name 1.0])
  end

  test "rejects array with 4 columns" do
    assert_not CsvRowValidator.valid_structure?(%w[name 1.0 2.0 extra])
  end

  test "rejects empty array" do
    assert_not CsvRowValidator.valid_structure?([])
  end

  # --- valid_data? ---

  test "accepts valid entry" do
    entry = { name: "Starbucks", latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with nil name" do
    entry = { name: nil, latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert_not CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with empty name" do
    entry = { name: "", latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert_not CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with name exceeding 255 characters" do
    long_name = "A" * 256
    entry = { name: long_name, latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert_not CsvRowValidator.valid_data?(entry)
  end

  test "accepts entry with name at exactly 255 characters" do
    name = "A" * 255
    entry = { name: name, latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with invalid name characters (script injection)" do
    entry = { name: "<script>alert('xss')</script>", latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert_not CsvRowValidator.valid_data?(entry)
  end

  test "accepts entry with unicode characters in name" do
    entry = { name: "Café Résumé", latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert CsvRowValidator.valid_data?(entry)
  end

  test "accepts entry with ampersand and apostrophe in name" do
    entry = { name: "Ben & Jerry's", latitude: BigDecimal("47.6"), longitude: BigDecimal("-122.4") }
    assert CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with out-of-range latitude" do
    entry = { name: "Shop", latitude: BigDecimal("999"), longitude: BigDecimal("-122.4") }
    assert_not CsvRowValidator.valid_data?(entry)
  end

  test "rejects entry with nil coordinates" do
    entry = { name: "Shop", latitude: nil, longitude: nil }
    assert_not CsvRowValidator.valid_data?(entry)
  end
end
