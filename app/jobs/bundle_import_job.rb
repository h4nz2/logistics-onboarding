class BundleImportJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    # TODO: Implement bundle import
    # 1. Find the OnboardingFileUpload by upload_id
    # 2. Parse the attached CSV/Excel file
    # 3. Create Bundle records
    # 4. Update upload.processing_status to "completed" or "failed"
  end
end
