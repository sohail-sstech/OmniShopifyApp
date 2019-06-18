class CreateProductExclusionTags < ActiveRecord::Migration[5.2]
  def change
    create_table :product_exclusion_tags do |t|
      t.references :shop
      # t.integer :shop_id
      t.string :tag

      t.timestamps
    end
  end
end
