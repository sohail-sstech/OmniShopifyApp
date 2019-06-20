class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :iso, limit: 2, null: true
      t.string :name, limit: 80, null: true
      t.string :nicename, limit: 80, null: true
      t.string :iso3, limit: 3, null: true
      t.integer :numcode, limit: 6, null: true
      t.integer :phonecode, limit: 5, null: true

      t.timestamps
    end
  end
end
