class CoffeeShopSerializer
  include JSONAPI::Serializer

  set_type :coffee_shop
  attributes :name, :latitude, :longitude

  attribute :distance do |object, params|
    params[:distances]&.dig(object.id)
  end

  def self.format_results(results, x:, y:)
    self.new(
      extract_shops(results),
      params: { distances: map_distances(results) },
      meta: build_meta(results, x, y)
    ).serializable_hash
  end

  def self.extract_shops(results)
    results.map { |r| r[:coffee_shop] }
  end

  def self.map_distances(results)
    results.to_h { |r| [r[:coffee_shop].id, r[:distance]] }
  end

  def self.build_meta(results, x, y)
    {
      origin: { x: x.to_f, y: y.to_f },
      count: results.size
    }
  end

  private_class_method :extract_shops, :map_distances, :build_meta
end