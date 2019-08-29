class RemoveTypeFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    remove_column :refund_detail_api_logs, :type, :integer
  end
end
