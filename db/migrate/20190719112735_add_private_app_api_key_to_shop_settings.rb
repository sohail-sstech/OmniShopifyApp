class AddPrivateAppApiKeyToShopSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_settings, :private_app_api_key, :string, :null => true
  end
end
