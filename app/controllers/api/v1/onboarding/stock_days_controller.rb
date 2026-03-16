module Api
  module V1
    module Onboarding
      class StockDaysController < BaseStepController
        def update
          unless params.key?(:stock_days)
            return render_error("stock_days is required", status: :unprocessable_entity)
          end

          stock_days = params[:stock_days].to_i

          if stock_days <= 0
            return render_error("Stock days must be a positive integer")
          end

          ActiveRecord::Base.transaction do
            @company.update!(stock_days: stock_days)
            complete_step!
          end
        end

        private

        def step_name
          "stock_days"
        end

        def after_complete
          RecalculateRestockingJob.perform_later(@company.id, "stock_days")
        end
      end
    end
  end
end
