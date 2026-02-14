require "net/http"
require "uri"

module Csv
  class Fetcher
    FetchError = Class.new(StandardError)

    def self.call(url)
      new(url: url).call
    end

    def initialize(url:, http_client: Net::HTTP)
      @url = url
      @http_client = http_client
    end

    def call
      response = @http_client.get_response(URI.parse(@url))
      raise FetchError, "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end
  end
end
