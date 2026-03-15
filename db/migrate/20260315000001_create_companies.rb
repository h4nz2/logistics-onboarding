class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.integer :lead_days
      t.integer :stock_days
      t.integer :forecasting_days
      t.timestamps
    end
  end
end
