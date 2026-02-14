require "csv"
module Csv
  class Parser
    def initialize(csv_content:, logger: Rails.logger)
      @csv_content = csv_content
      @logger = logger
    end

    def self.call(csv_content)
      new(csv_content: csv_content).call
    end

    def call
      return [] if @csv_content.blank?

      @csv_content.each_line.with_index(1).filter_map do |line, line_number|
        extract_row_attributes(line.strip, line_number)
      end
    end

    private

    def extract_row_attributes(row, line_number)
      return nil if row.blank?

      columns = extract_columns(row)
      return skip_csv_row(line_number, row) unless CsvRowValidator.valid_structure?(columns)

      entry = build_coffee_shop(columns)
      return skip_csv_row(line_number, row) unless CsvRowValidator.valid_data?(entry)

      entry
    end

    def build_coffee_shop(columns)
      {
        name: columns[0],
        latitude: CoordinateValidator.to_decimal(columns[1]),
        longitude: CoordinateValidator.to_decimal(columns[2])
      }
    end

    def extract_columns(row)
      CSV.parse_line(row)&.map { |col| col&.strip.to_s } || []
    end

    def skip_csv_row(line_number, row)
      @logger.warn("[CsvParser] Skipping malformed line #{line_number}: '#{row}'")
      nil
    end
  end
end
