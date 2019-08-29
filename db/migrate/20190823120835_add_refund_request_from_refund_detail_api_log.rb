class AddRefundRequestFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_detail_api_logs, :refund_request, :text, null: true
  end
end
