# frozen_string_literal: true

FactoryBot.define do
  factory :coffee_shop do
    sequence(:name) { |n| "Coffee Shop #{n}" }
    latitude { rand(-90.0..90.0).round(4) }
    longitude { rand(-180.0..180.0).round(4) }
    address { "#{rand(100..999)} Main Street" }
    schedule { "Mon-Fri: 7:00-19:00" }
  end
end
