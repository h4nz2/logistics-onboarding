class CreateProductsVendors < ActiveRecord::Migration[8.1]
  def change
    create_table :products_vendors, id: false do |t|
      t.references :product, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
    end

    add_index :products_vendors, [:product_id, :vendor_id], unique: true
  end
end
