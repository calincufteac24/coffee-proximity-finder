class AddAddressAndOpeningHoursToCoffeeShops < ActiveRecord::Migration[8.1]
  def change
    add_column :coffee_shops, :address, :string
    add_column :coffee_shops, :schedule, :string
  end
end
