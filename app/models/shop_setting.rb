class ShopSetting < ApplicationRecord
    validates :token, presence: { message: 'Please enter Access Token.' }
end
