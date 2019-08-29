class CreateRefundDetailApiLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_detail_api_logs do |t|
      # t.integer :shop_id
      t.references :shop
      t.integer :refund_detail_id, limit: 20, null: false
      t.text :request, null: true
      t.text :response, null: true
      t.integer :type, limit: 2, null: false, comment: '1 = Refund, 2 = Store Credit'
      t.integer :status, limit: 2, null: false, default: '0', comment: '0 = Failure, 1 = Success'

      t.timestamps
    end
  end
end
