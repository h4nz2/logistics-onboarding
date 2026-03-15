class AddCompanyToBundlesAndProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :bundles, :company, null: false, foreign_key: true
    add_reference :products, :company, null: false, foreign_key: true
  end
end
