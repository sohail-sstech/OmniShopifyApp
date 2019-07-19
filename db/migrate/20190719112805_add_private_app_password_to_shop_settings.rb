class AddPrivateAppPasswordToShopSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_settings, :private_app_password, :string, :null => true
  end
end
