class AddSpOrderLineItemIdToRefundDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_details, :sp_order_line_item_id, :integer, null: true
  end
end
