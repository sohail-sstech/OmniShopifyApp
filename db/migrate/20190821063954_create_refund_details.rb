class CreateRefundDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_details do |t|
      # t.integer :shop_id
      t.references :shop
      t.integer :sp_customer_id, limit: 20, null: false
      t.integer :sp_order_id, limit: 20, null: false
      t.integer :sp_product_id, limit: 20, null: false
      t.string :sp_order_no, limit: 255, null: true
      t.string :sp_product_sku, limit: 255, null: true
      t.string :sp_gift_card_code, limit: 255, null: true
      t.integer :refund_type, limit: 2, null: false, comment: '1 = Refund, 2 = Store Credit'
      t.integer :refund_status, limit: 2, null: false, default: '0', comment: '0 = Failure, 1 = Success'
      t.text :status_message, null: true

      t.timestamps
    end
  end
end
