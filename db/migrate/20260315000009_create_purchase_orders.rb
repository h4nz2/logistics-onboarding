class CreatePurchaseOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_orders do |t|
      t.references :company, null: false, foreign_key: true
      t.date :order_date, null: false

      t.timestamps
    end
  end
end
