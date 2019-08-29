class AddRefundStatusFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_detail_api_logs, :refund_status, :integer, limit: 2, null: true, default: '0', comment: '0 = Failure, 1 = Success'
  end
end
