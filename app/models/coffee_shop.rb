class CoffeeShop < ApplicationRecord
  MAX_NAME_LENGTH = 255
  MAX_ADDRESS_LENGTH = 500
  MAX_SCHEDULE_LENGTH = 255

  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
  validates :latitude, presence: true,
                       numericality: { greater_than_or_equal_to: -90,
                                       less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
                        numericality: { greater_than_or_equal_to: -180,
                                        less_than_or_equal_to: 180 }
  validates :external_id, presence: true, uniqueness: true
  validates :address, length: { maximum: MAX_ADDRESS_LENGTH }, allow_blank: true
  validates :schedule, length: { maximum: MAX_SCHEDULE_LENGTH }, allow_blank: true

  before_validation :generate_external_id, if: -> { external_id.blank? }

  def self.generate_external_id(name:, latitude:, longitude:)
    Digest::SHA256.hexdigest("#{name}|#{latitude}|#{longitude}")
  end

  private

  def generate_external_id
    self.external_id = self.class.generate_external_id(
      name: name,
      latitude: latitude,
      longitude: longitude
    )
  end
end
