class CreateRuleOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :rule_options do |t|
      # t.integer :shop_id, limit: 11
      t.references :shop
      # t.integer :rule_id, limit: 11
      t.references :rule
      t.integer :refund_method, limit: 3, null: true, default: 1
      t.integer :return_window, limit: 3, null: true, default: 0
      t.integer :return_shipping_fee, limit: 2, null: true, default: 0

      t.timestamps
    end
  end
end
