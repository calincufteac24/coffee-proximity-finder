class CoffeeShopSynchronizer
  def call
    @shops = fetch_parsed_data
    return if @shops.empty?

    @records = load_existing_records
    sync_all_shops
  end

  private

  def fetch_parsed_data
    Csv::Parser.call(Csv::Fetcher.call(csv_url))
  end

  def load_existing_records
    ids = @shops.map { |attrs| external_id(attrs) }
    CoffeeShop.where(external_id: ids).index_by(&:external_id)
  end

  def sync_all_shops
    @shops.each { |attrs| sync_shop(attrs) }
  end

  def sync_shop(attrs)
    id = external_id(attrs)
    record = @records[id] || CoffeeShop.new(external_id: id)

    persist(record, attrs, id)
  end

  def persist(record, attrs, id)
    record.update!(attrs)
  rescue ActiveRecord::RecordNotUnique
    record = CoffeeShop.find_by!(external_id: id)
    record.update!(attrs)
  ensure
    @records[id] = record
  end

  def external_id(attrs)
    CoffeeShop.generate_external_id(**attrs.slice(:name, :latitude, :longitude))
  end

  def csv_url
    Rails.configuration.x.csv_source_url
  end
end
