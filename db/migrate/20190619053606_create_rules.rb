class CreateRules < ActiveRecord::Migration[5.2]
  def change
    create_table :rules do |t|
      # t.integer :shop_id, limit: 11
      t.references :shop
      t.string :name, limit: 80
      t.integer :priority, limit: 5, default: 1
      t.text :conditions

      t.timestamps
    end
  end
end
