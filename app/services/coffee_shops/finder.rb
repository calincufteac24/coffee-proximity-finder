module CoffeeShops
  class Finder
    KM_PER_DEGREE = 111.12
    Result = Data.define(:coffee_shop, :distance)

    def initialize(latitude:, longitude:, limit: 3, scope: CoffeeShop.all)
      @latitude = latitude.to_f
      @longitude = longitude.to_f
      @limit = limit
      @scope = scope
    end

    def call
      closest_shops.map { |shop| Result.new(coffee_shop: shop, distance: shop.distance) }
    end

    private

    def closest_shops
      @scope
        .select("coffee_shops.*, #{distance_sql} AS distance")
        .order("distance ASC")
        .limit(@limit)
    end

    def distance_sql
      sanitize(
        "(#{KM_PER_DEGREE} * SQRT(POWER(latitude - ?, 2) + POWER(longitude - ?, 2)))",
        @latitude, @longitude
      )
    end

    def sanitize(sql, *values)
      ActiveRecord::Base.sanitize_sql_array([ sql, *values ])
    end
  end
end
