class CreateIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :integrations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :provider, null: false
      t.jsonb :configuration, default: {}

      t.timestamps
    end

    add_index :integrations, [:company_id, :provider], unique: true
  end
end
