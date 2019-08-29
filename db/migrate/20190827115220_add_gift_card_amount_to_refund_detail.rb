class AddGiftCardAmountToRefundDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_details, :gift_card_amount, :float, null: true
  end
end
