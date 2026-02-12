class DataValidator
  LATITUDE_RANGE = (-90..90)
  LONGITUDE_RANGE = (-180..180)
  COORDINATE_FORMAT = /\A-?\d+(\.\d+)?\z/

  EXPECTED_COLUMNS = 3
  MAX_NAME_LENGTH = 255
  VALID_NAME_PATTERN = /\A[\p{L}\p{N}\s\-'.&,()]+\z/

  def self.valid_latitude?(value)
    in_range?(value, LATITUDE_RANGE)
  end

  def self.valid_longitude?(value)
    in_range?(value, LONGITUDE_RANGE)
  end

  def self.to_decimal(value)
    return value if value.is_a?(BigDecimal)
    return nil unless value.to_s.match?(COORDINATE_FORMAT)

    BigDecimal(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def self.valid_data?(entry)
    valid_name?(entry[:name]) && valid_coordinates?(entry[:latitude], entry[:longitude])
  end

  def self.valid_name?(name)
    name.present? && name.length <= MAX_NAME_LENGTH && name.match?(VALID_NAME_PATTERN)
  end

  def self.valid_coordinates?(lat, lng)
    valid_latitude?(lat) && valid_longitude?(lng)
  end

  def self.valid_structure?(columns)
    columns.size == EXPECTED_COLUMNS
  end

  def self.in_range?(value, range)
    decimal = to_decimal(value)
    decimal && range.cover?(decimal)
  end

  private_class_method :in_range?
end
