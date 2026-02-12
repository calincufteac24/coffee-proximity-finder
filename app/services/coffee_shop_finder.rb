class CoffeeShopFinder
  def initialize(x:, y:, limit: 3, scope: CoffeeShop.all)
    @origin_latitude = BigDecimal(x.to_s)
    @origin_longitude = BigDecimal(y.to_s)
    @max_results = limit
    @coffee_shops = scope
  end

  def call
    @coffee_shops.map { |shop| coffee_shop_with_distance(shop) }
                 .sort_by { |result| result[:distance] }
                 .first(@max_results)
  end

  private

  def coffee_shop_with_distance(shop)
    { coffee_shop: shop, distance: calculate_distance(shop.latitude, shop.longitude) }
  end

  def calculate_distance(latitude, longitude)
    latitude_difference = BigDecimal(latitude.to_s) - @origin_latitude
    longitude_difference = BigDecimal(longitude.to_s) - @origin_longitude

    # 1 degree is approximately 111.12 km
    degree_distance = Math.sqrt((latitude_difference**2 + longitude_difference**2).to_f)
    (degree_distance * 111.12).round(4)
  end
end
