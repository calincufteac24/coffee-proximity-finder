class CoordinateValidator
  LATITUDE_RANGE = (-90..90)
  LONGITUDE_RANGE = (-180..180)
  COORDINATE_FORMAT = /\A-?\d+(\.\d+)?\z/

  def self.valid_latitude?(value)
    in_range?(value, LATITUDE_RANGE)
  end

  def self.valid_longitude?(value)
    in_range?(value, LONGITUDE_RANGE)
  end

  def self.valid?(latitude, longitude)
    valid_latitude?(latitude) && valid_longitude?(longitude)
  end

  def self.to_decimal(value)
    return value if value.is_a?(BigDecimal)
    return nil unless value.to_s.match?(COORDINATE_FORMAT)

    BigDecimal(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def self.in_range?(value, range)
    decimal = to_decimal(value)
    decimal && range.cover?(decimal)
  end

  private_class_method :in_range?
end
