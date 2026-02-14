class CreateCoffeeShops < ActiveRecord::Migration[8.1]
  def change
    create_table :coffee_shops, if_not_exists: true do |t|
      t.string  :name,        null: false
      t.decimal :latitude,    null: false, precision: 10, scale: 6
      t.decimal :longitude,   null: false, precision: 10, scale: 6
      t.string  :external_id, null: false

      t.timestamps
    end

    add_index :coffee_shops, :external_id, unique: true
    add_index :coffee_shops, %i[latitude longitude]
  end
end
