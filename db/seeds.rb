COFFEE_SHOPS = [
  { name: "Starbucks - Central", latitude: 47.6062, longitude: -122.3321, address: "1124 Pike St, Seattle, WA 98101", schedule: "Mon-Fri: 5:30-21:00, Sat-Sun: 6:00-20:00" },
  { name: "Coffee Bean Delight", latitude: 47.6097, longitude: -122.3425, address: "401 Broadway E, Seattle, WA 98102", schedule: "Mon-Fri: 6:00-19:00, Sat: 7:00-18:00" },
  { name: "Brewed Awakenings", latitude: 47.6145, longitude: -122.3440, address: "720 E Pine St, Seattle, WA 98122", schedule: "Mon-Sun: 6:30-20:00" },
  { name: "Cafe Mocha", latitude: 47.6205, longitude: -122.3493, address: "1501 12th Ave, Seattle, WA 98122", schedule: "Mon-Fri: 7:00-18:00, Sat-Sun: 8:00-17:00" },
  { name: "Espresso Express", latitude: 47.6010, longitude: -122.3328, address: "305 Harrison St, Seattle, WA 98109", schedule: "Mon-Fri: 5:00-15:00" },
  { name: "The Daily Grind", latitude: 47.6232, longitude: -122.3210, address: "219 Broadway E, Seattle, WA 98102", schedule: "Mon-Sat: 6:00-20:00, Sun: 7:00-18:00" },
  { name: "Drip & Sip", latitude: 47.6155, longitude: -122.3560, address: "900 Madison St, Seattle, WA 98104", schedule: "Mon-Fri: 6:30-19:30, Sat-Sun: 7:30-17:00" },
  { name: "Arabica House", latitude: 47.5985, longitude: -122.3270, address: "1600 E Olive Way, Seattle, WA 98122", schedule: "Mon-Sun: 7:00-21:00" },
  { name: "Morning Ritual", latitude: 47.6180, longitude: -122.3380, address: "515 Westlake Ave N, Seattle, WA 98109", schedule: "Mon-Fri: 5:30-14:00, Sat: 6:30-14:00" },
  { name: "Roast Republic", latitude: 47.6088, longitude: -122.3155, address: "2200 1st Ave S, Seattle, WA 98134", schedule: "Mon-Fri: 6:00-18:00, Sat-Sun: 7:00-16:00" }
].freeze

COFFEE_SHOPS.each do |attrs|
  CoffeeShop.find_or_create_by!(name: attrs[:name]) do |shop|
    shop.assign_attributes(attrs.except(:name))
  end
end

Rails.logger.info "Seeded #{CoffeeShop.count} coffee shops"
