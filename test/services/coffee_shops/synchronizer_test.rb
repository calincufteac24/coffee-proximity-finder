# frozen_string_literal: true

require "test_helper"

class CoffeeShops::SynchronizerTest < ActiveSupport::TestCase
  setup do
    @valid_csv = "Test Shop,40.0,-74.0\nAnother Shop,41.0,-73.0"
  end

  test "creates new coffee shops from CSV data" do
    CoffeeShop.delete_all

    sync_with_csv(@valid_csv)

    assert_equal 2, CoffeeShop.count
    assert CoffeeShop.find_by(name: "Test Shop")
    assert CoffeeShop.find_by(name: "Another Shop")
  end

  test "updates existing coffee shops on re-sync (idempotent)" do
    CoffeeShop.delete_all

    sync_with_csv(@valid_csv)
    initial_count = CoffeeShop.count

    sync_with_csv(@valid_csv)

    assert_equal initial_count, CoffeeShop.count
  end

  test "does nothing when CSV is empty" do
    initial_count = CoffeeShop.count

    sync_with_csv("")

    assert_equal initial_count, CoffeeShop.count
  end

  test "does nothing when all rows are malformed" do
    CoffeeShop.delete_all

    sync_with_csv("bad_line\nanother_bad")

    assert_equal 0, CoffeeShop.count
  end

  test "skips malformed rows and processes valid ones" do
    CoffeeShop.delete_all

    sync_with_csv("bad_line\nGood Shop,45.0,-90.0\n,invalid")

    assert_equal 1, CoffeeShop.count
    assert_equal "Good Shop", CoffeeShop.first.name
  end

  test "handles fetch error gracefully without crashing" do
    initial_count = CoffeeShop.count

    sync_with_fetch_error("HTTP 500")

    assert_equal initial_count, CoffeeShop.count
  end

  test "logs error when fetch fails" do
    log_output = StringIO.new
    original_logger = Rails.logger

    begin
      Rails.logger = Logger.new(log_output)
      sync_with_fetch_error("HTTP 500")
    ensure
      Rails.logger = original_logger
    end

    assert_match(/Failed to fetch CSV/, log_output.string)
  end

  test "sets timestamps on upserted records" do
    CoffeeShop.delete_all

    freeze_time do
      sync_with_csv("Timestamped Shop,45.0,-90.0")

      shop = CoffeeShop.find_by(name: "Timestamped Shop")
      assert_not_nil shop.created_at
      assert_not_nil shop.updated_at
    end
  end

  test "generates correct external_id for each record" do
    CoffeeShop.delete_all

    sync_with_csv("ID Test,50.0,10.0")

    shop = CoffeeShop.find_by(name: "ID Test")
    expected_id = CoffeeShop.generate_external_id(name: "ID Test", latitude: BigDecimal("50.0"), longitude: BigDecimal("10.0"))
    assert_equal expected_id, shop.external_id
  end

  test "handles large datasets without error" do
    CoffeeShop.delete_all
    lines = 50.times.map { |i| "Shop #{i},#{(40.0 + i * 0.01).round(4)},#{(-74.0 + i * 0.01).round(4)}" }

    sync_with_csv(lines.join("\n"))

    assert_equal 50, CoffeeShop.count
  end

  private

  def sync_with_csv(csv_content)
    fetcher_stub = Module.new do
      define_method(:call) { |_url| csv_content }
    end

    original_call = Csv::Fetcher.method(:call)
    Csv::Fetcher.define_singleton_method(:call) { |url| csv_content }

    CoffeeShops::Synchronizer.new.call
  ensure
    Csv::Fetcher.define_singleton_method(:call, original_call)
  end

  def sync_with_fetch_error(message)
    original_call = Csv::Fetcher.method(:call)
    Csv::Fetcher.define_singleton_method(:call) { |_url| raise Csv::Fetcher::FetchError, message }

    CoffeeShops::Synchronizer.new.call
  ensure
    Csv::Fetcher.define_singleton_method(:call, original_call)
  end
end
