class CreateSalesHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_histories do |t|
      t.references :product, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :quantity, null: false

      t.timestamps
    end

    add_index :sales_histories, [:product_id, :date]
  end
end
