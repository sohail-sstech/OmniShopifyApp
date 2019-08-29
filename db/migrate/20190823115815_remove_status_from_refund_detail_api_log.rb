class RemoveStatusFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    remove_column :refund_detail_api_logs, :status, :integer
  end
end
