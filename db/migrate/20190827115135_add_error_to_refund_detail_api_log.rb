class AddErrorToRefundDetailApiLog < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_detail_api_logs, :error, :text, null: true
  end
end
