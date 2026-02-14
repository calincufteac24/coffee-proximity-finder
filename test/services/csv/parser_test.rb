# frozen_string_literal: true

require "test_helper"

class Csv::ParserTest < ActiveSupport::TestCase
  test "parses valid CSV content" do
    csv = "Starbucks,47.6,-122.4\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 2, results.size
    assert_equal "Starbucks", results[0][:name]
    assert_equal BigDecimal("47.6"), results[0][:latitude]
    assert_equal BigDecimal("-122.4"), results[0][:longitude]
  end

  test "returns empty array for nil content" do
    assert_equal [], Csv::Parser.call(nil)
  end

  test "returns empty array for empty string" do
    assert_equal [], Csv::Parser.call("")
  end

  test "returns empty array for blank string" do
    assert_equal [], Csv::Parser.call("   ")
  end

  test "skips blank lines" do
    csv = "Starbucks,47.6,-122.4\n\n\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 2, results.size
  end

  test "skips lines with wrong number of columns" do
    csv = "Starbucks,47.6\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Peets", results[0][:name]
  end

  test "skips lines with too many columns" do
    csv = "Starbucks,47.6,-122.4,extra\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Peets", results[0][:name]
  end

  test "skips lines with invalid coordinates" do
    csv = "Starbucks,999,-122.4\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Peets", results[0][:name]
  end

  test "skips lines with non-numeric coordinates" do
    csv = "Starbucks,abc,xyz\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
  end

  test "skips lines with empty name" do
    csv = ",47.6,-122.4\nPeets,37.5,-122.3"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Peets", results[0][:name]
  end

  test "logs warning for skipped malformed lines" do
    log_output = StringIO.new
    logger = Logger.new(log_output)

    Csv::Parser.new(csv_content: "bad_data,not_a_number,also_not", logger: logger).call

    assert_match(/Skipping malformed line/, log_output.string)
  end

  test "strips whitespace from columns" do
    csv = "  Starbucks  ,  47.6  ,  -122.4  "
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Starbucks", results[0][:name]
  end

  test "handles CSV with quoted fields containing commas" do
    csv = "\"Starbucks, Pike Place\",47.6,-122.4"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
    assert_equal "Starbucks, Pike Place", results[0][:name]
  end

  test "handles completely malformed CSV gracefully" do
    csv = "!!!@@@###\n$$$%%%^^^"
    results = Csv::Parser.call(csv)

    assert_equal [], results
  end

  test "parses single valid line" do
    csv = "Starbucks,47.6,-122.4"
    results = Csv::Parser.call(csv)

    assert_equal 1, results.size
  end

  test "returns correct types for coordinates" do
    csv = "Starbucks,47.6,-122.4"
    results = Csv::Parser.call(csv)

    assert_instance_of BigDecimal, results[0][:latitude]
    assert_instance_of BigDecimal, results[0][:longitude]
  end
end
