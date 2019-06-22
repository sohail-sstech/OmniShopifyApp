class Rule < ApplicationRecord
    validates :name, presence: { message: 'Please enter Rule Name.' }
end
