class CsvRowValidator
  EXPECTED_COLUMNS = 3
  MAX_NAME_LENGTH = 255
  VALID_NAME_PATTERN = /\A[\p{L}\p{N}\s\-'.&,()]+\z/

  def self.valid_structure?(columns)
    columns.size == EXPECTED_COLUMNS
  end

  def self.valid_data?(entry)
    valid_name?(entry[:name]) && CoordinateValidator.valid?(entry[:latitude], entry[:longitude])
  end

  def self.valid_name?(name)
    name.present? && name.length <= MAX_NAME_LENGTH && name.match?(VALID_NAME_PATTERN)
  end

  private_class_method :valid_name?
end
