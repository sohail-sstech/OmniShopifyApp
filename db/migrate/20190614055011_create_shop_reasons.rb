class CreateShopReasons < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_reasons do |t|
      t.references :shop
      t.string :reason_ids

      t.timestamps
    end
  end
end
