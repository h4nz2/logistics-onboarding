class PurchaseOrderImportJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    # TODO: Implement purchase order import
    # 1. Find the OnboardingFileUpload by upload_id
    # 2. Parse the attached CSV/Excel file
    # 3. Create PurchaseOrder and PurchaseOrderItem records
    # 4. Update upload.processing_status to "completed" or "failed"
  end
end
