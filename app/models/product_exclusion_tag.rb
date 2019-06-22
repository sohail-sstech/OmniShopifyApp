class ProductExclusionTag < ApplicationRecord
    validates :tag, presence: { message: 'Please enter comma separated product exclusion tags.' }
end
