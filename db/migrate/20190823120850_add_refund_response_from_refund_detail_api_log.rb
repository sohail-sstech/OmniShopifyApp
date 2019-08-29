class AddRefundResponseFromRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_detail_api_logs, :refund_response, :text, null: true
  end
end
