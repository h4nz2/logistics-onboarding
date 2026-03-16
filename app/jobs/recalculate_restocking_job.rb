class RecalculateRestockingJob < ApplicationJob
  queue_as :default

  def perform(company_id, changed_attribute)
    company = Company.find(company_id)

    # TODO: Implement restocking recalculation
    # This job is triggered when a logistics configuration value changes during onboarding.
    # The `changed_attribute` parameter indicates what changed: "lead_days", "stock_days", or "forecasting_days"
    #
    # Depending on the changed attribute:
    # - lead_days: Recalculate reorder points for all products (when to place new orders)
    # - stock_days: Recalculate safety stock levels for all products (how much inventory to maintain)
    # - forecasting_days: Recalculate daily average sales and all dependent predictions

    Rails.logger.info("RecalculateRestockingJob: #{changed_attribute} changed for company #{company.id}")
  end
end
