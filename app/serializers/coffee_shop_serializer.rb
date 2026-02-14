class CoffeeShopSerializer
  include JSONAPI::Serializer

  set_type :coffee_shop
  attributes :name, :latitude, :longitude

  attribute :distance do |shop, params|
    params[:distances]&.dig(shop.id)
  end

  def self.serialize_search_results(results, latitude:, longitude:)
    self.new(
      extract_shops(results),
      params: { distances: map_distances(results) },
      meta: build_metadata(results, latitude, longitude)
    ).serializable_hash
  end

  def self.extract_shops(results)
    results.map(&:coffee_shop)
  end

  def self.map_distances(results)
    results.to_h { |res| [res.coffee_shop.id, res.distance] }
  end

  def self.build_metadata(results, lat, lng)
    {
      origin: { latitude: lat.to_f, longitude: lng.to_f },
      total_count: results.size,
      last_synced_at: CoffeeShop.maximum(:updated_at)&.iso8601
    }
  end

  private_class_method :extract_shops, :map_distances, :build_metadata
end
