COFFEE_SHOPS = [
  {
    name: "Starbucks - Central",
    latitude: 47.6062,
    longitude: -122.3321,
    address: "123 Main Street, Downtown, Seattle",
    schedule: "Mon-Fri: 6:00-22:00, Sat-Sun: 7:00-21:00"
  },
  {
    name: "Coffee Bean Delight",
    latitude: 47.6097,
    longitude: -122.3425,
    address: "456 Pike Place, Waterfront, Seattle",
    schedule: "Mon-Sun: 7:00-20:00"
  },
  {
    name: "Brewed Awakenings",
    latitude: 47.6145,
    longitude: -122.3440,
    address: "443 Hipster Ave, Riverside, Seattle",
    schedule: "Mon-Fri: 6:30-19:00, Sat: 8:00-17:00"
  },
  {
    name: "Cafe Mocha",
    latitude: 47.6205,
    longitude: -122.3493,
    address: "789 Latte Lane, Capitol Hill, Seattle",
    schedule: "Mon-Sun: 8:00-22:00"
  },
  {
    name: "Espresso Express",
    latitude: 47.6010,
    longitude: -122.3328,
    address: "321 Bean Blvd, Pioneer Square, Seattle",
    schedule: "Mon-Fri: 5:30-18:00"
  },
  {
    name: "The Daily Grind",
    latitude: 47.6232,
    longitude: -122.3210,
    address: "55 Roast Road, Eastlake, Seattle",
    schedule: "Mon-Sat: 7:00-21:00, Sun: 9:00-17:00"
  },
  {
    name: "Drip & Sip",
    latitude: 47.6155,
    longitude: -122.3560,
    address: "88 Filter St, Queen Anne, Seattle",
    schedule: "Mon-Fri: 6:00-20:00, Sat-Sun: 8:00-19:00"
  },
  {
    name: "Arabica House",
    latitude: 47.5985,
    longitude: -122.3270,
    address: "12 Origin Ave, International District, Seattle",
    schedule: "Mon-Sun: 7:00-23:00"
  },
  {
    name: "Morning Ritual",
    latitude: 47.6180,
    longitude: -122.3380,
    address: "99 Sunrise Blvd, Belltown, Seattle",
    schedule: "Mon-Fri: 5:00-14:00"
  },
  {
    name: "Roast Republic",
    latitude: 47.6088,
    longitude: -122.3155,
    address: "200 Craft Circle, First Hill, Seattle",
    schedule: "Mon-Sat: 6:30-21:00, Sun: 8:00-18:00"
  }
].freeze

COFFEE_SHOPS.each do |attrs|
  CoffeeShop.find_or_create_by!(name: attrs[:name]) do |shop|
    shop.assign_attributes(attrs.except(:name))
  end
end

Rails.logger.info "Seeded #{CoffeeShop.count} coffee shops"
