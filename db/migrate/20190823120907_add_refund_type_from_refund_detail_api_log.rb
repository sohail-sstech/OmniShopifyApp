class AddRefundTypeFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_detail_api_logs, :refund_type, :integer, limit: 2, null: true, comment: '1 = Refund, 2 = Store Credit'
  end
end
