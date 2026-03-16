class CreateIntegrationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :integration_requests do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
