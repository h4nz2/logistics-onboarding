class BundleImportJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = OnboardingFileUpload.find(upload_id)

    # TODO: Implement bundle import
    # 1. Parse the attached CSV/Excel file
    # 2. Create Bundle records

    upload.update!(processing_status: "completed")
  rescue StandardError => e
    upload&.update!(processing_status: "failed", error_message: e.message)
  end
end
