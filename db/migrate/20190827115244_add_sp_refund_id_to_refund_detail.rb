class AddSpRefundIdToRefundDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_details, :sp_refund_id, :integer, null: true
  end
end
