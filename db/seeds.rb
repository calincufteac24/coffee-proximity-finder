COFFEE_SHOPS = [
  { name: "Starbucks - Central", latitude: 47.6062, longitude: -122.3321 },
  { name: "Coffee Bean Delight", latitude: 47.6097, longitude: -122.3425 },
  { name: "Brewed Awakenings", latitude: 47.6145, longitude: -122.3440 },
  { name: "Cafe Mocha", latitude: 47.6205, longitude: -122.3493 },
  { name: "Espresso Express", latitude: 47.6010, longitude: -122.3328 },
  { name: "The Daily Grind", latitude: 47.6232, longitude: -122.3210 },
  { name: "Drip & Sip", latitude: 47.6155, longitude: -122.3560 },
  { name: "Arabica House", latitude: 47.5985, longitude: -122.3270 },
  { name: "Morning Ritual", latitude: 47.6180, longitude: -122.3380 },
  { name: "Roast Republic", latitude: 47.6088, longitude: -122.3155 }
].freeze

COFFEE_SHOPS.each do |attrs|
  CoffeeShop.find_or_create_by!(name: attrs[:name]) do |shop|
    shop.assign_attributes(attrs.except(:name))
  end
end

Rails.logger.info "Seeded #{CoffeeShop.count} coffee shops"
