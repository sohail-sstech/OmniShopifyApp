class AddShopIdToReasons < ActiveRecord::Migration[5.2]
  def change
    add_column :reasons, :shop_id, :integer
  end
end
