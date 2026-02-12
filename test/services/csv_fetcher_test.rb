# frozen_string_literal: true

require "test_helper"

class CsvFetcherTest < ActiveSupport::TestCase
  test "returns success result when HTTP response is 200" do
    stub_response = Net::HTTPSuccess.new("1.1", "200", "OK")
    stub_response.instance_variable_set(:@body, "Shop,1.0,2.0")
    stub_response.instance_variable_set(:@read, true)

    mock_http = Minitest::Mock.new
    mock_http.expect(:get_response, stub_response, [URI.parse("https://example.com/data.csv")])

    fetcher = CsvFetcher.new(url: "https://example.com/data.csv", http_client: mock_http)
    result = fetcher.call

    assert result.success?
    assert_equal "Shop,1.0,2.0", result.body
    assert_nil result.error
    mock_http.verify
  end

  test "returns failure result when HTTP response is not success" do
    stub_response = Net::HTTPServerError.new("1.1", "500", "Internal Server Error")

    mock_http = Minitest::Mock.new
    mock_http.expect(:get_response, stub_response, [URI.parse("https://example.com/data.csv")])

    fetcher = CsvFetcher.new(url: "https://example.com/data.csv", http_client: mock_http)
    result = fetcher.call

    assert_not result.success?
    assert_nil result.body
    assert_includes result.error, "500"
    mock_http.verify
  end

  test "returns failure result when a network error occurs" do
    mock_http = Minitest::Mock.new
    mock_http.expect(:get_response, nil) { raise SocketError, "Connection refused" }

    fetcher = CsvFetcher.new(url: "https://example.com/data.csv", http_client: mock_http)
    result = fetcher.call

    assert_not result.success?
    assert_nil result.body
    assert_equal "Connection refused", result.error
  end
end
