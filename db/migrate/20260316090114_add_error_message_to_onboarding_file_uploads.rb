class AddErrorMessageToOnboardingFileUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :onboarding_file_uploads, :error_message, :text
  end
end
