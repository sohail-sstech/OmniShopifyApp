class AddSpGiftCardIdToRefundDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_details, :sp_gift_card_id, :integer, null: true
  end
end
