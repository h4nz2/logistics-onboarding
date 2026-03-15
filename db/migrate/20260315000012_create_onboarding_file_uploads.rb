class CreateOnboardingFileUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_file_uploads do |t|
      t.references :company, null: false, foreign_key: true
      t.string :step, null: false
      t.string :processing_status, null: false, default: "pending"

      t.timestamps
    end
  end
end
