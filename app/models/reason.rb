class Reason < ApplicationRecord
    validates :reason, presence: { message: 'Please enter Return Reason.' }
end
