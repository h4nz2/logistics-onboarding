class CreateBundlesProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :bundles_products, id: false do |t|
      t.references :bundle, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
    end

    add_index :bundles_products, [:bundle_id, :product_id], unique: true
  end
end
