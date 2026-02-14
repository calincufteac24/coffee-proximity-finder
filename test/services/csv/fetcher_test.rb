# frozen_string_literal: true

require "test_helper"

class Csv::FetcherTest < ActiveSupport::TestCase
  test "returns body when HTTP response is successful" do
    stub_http = build_stub_http(Net::HTTPSuccess, "200", "OK", "Shop,1.0,2.0")

    result = Csv::Fetcher.new(url: "https://example.com/data.csv", http_client: stub_http).call

    assert_equal "Shop,1.0,2.0", result
  end

  test "raises FetchError when HTTP response is 500" do
    stub_http = build_stub_http(Net::HTTPServerError, "500", "Internal Server Error")

    error = assert_raises(Csv::Fetcher::FetchError) do
      Csv::Fetcher.new(url: "https://example.com/data.csv", http_client: stub_http).call
    end

    assert_includes error.message, "500"
  end

  test "raises FetchError when HTTP response is 404" do
    stub_http = build_stub_http(Net::HTTPNotFound, "404", "Not Found")

    assert_raises(Csv::Fetcher::FetchError) do
      Csv::Fetcher.new(url: "https://example.com/data.csv", http_client: stub_http).call
    end
  end

  private

  def build_stub_http(response_class, code, message, body = nil)
    response = response_class.new("1.1", code, message)
    if body
      response.instance_variable_set(:@body, body)
      response.instance_variable_set(:@read, true)
    end

    stub_client = Object.new
    stub_client.define_singleton_method(:get_response) { |_uri| response }
    stub_client
  end
end
