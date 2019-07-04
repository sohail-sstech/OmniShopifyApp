class CreateShopSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_settings do |t|
      # t.integer :shop_id
      t.references :shop
      t.string :token, limit: 255, null: true
      t.integer :create_order_webhook_id, limit: 20, null: true
      t.integer :uninstall_app_webhook_id, limit: 20, null: true

      t.timestamps
    end
  end
end
