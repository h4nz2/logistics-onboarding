class CreateOnboardingSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_steps do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :step, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :onboarding_steps, %i[company_id step], unique: true
  end
end
