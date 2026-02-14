module CoffeeShops
  class Synchronizer
    BATCH_SIZE = 1_000
    # Note: upsert_all skips ActiveRecord validations by design.
    # Data integrity is enforced upstream by Csv::Parser + DataValidator,
    # and at the DB level by column constraints and unique indexes.
    def call
      shops = fetch_parsed_data
      return if shops.empty?

      upsert_in_batches(shops)
    end

    private

    def fetch_parsed_data
      raw_csv = Csv::Fetcher.call(csv_url)
      Csv::Parser.call(raw_csv)
    rescue Csv::Fetcher::FetchError => e
      Rails.logger.error("[CoffeeShop::Synchronizer] Failed to fetch CSV: #{e.message}")
      []
    end

    def upsert_in_batches(shops)
      shops.each_slice(BATCH_SIZE) do |batch|
        records = batch.map { |attrs| build_record(attrs) }

        CoffeeShop.upsert_all(records, unique_by: :external_id)
      end
    end

    def build_record(attrs)
      now = Time.current

      attrs.merge(
        external_id: generate_external_id(attrs),
        created_at: now,
        updated_at: now
      )
    end

    def generate_external_id(attrs)
      CoffeeShop.generate_external_id(**attrs.slice(:name, :latitude, :longitude))
    end

    def csv_url
      Rails.configuration.x.csv_source_url
    end
  end
end

