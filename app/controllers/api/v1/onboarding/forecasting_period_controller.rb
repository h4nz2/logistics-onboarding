module Api
  module V1
    module Onboarding
      class ForecastingPeriodController < BaseStepController
        def update
          unless params.key?(:forecasting_days)
            return render_error("forecasting_days is required", status: :unprocessable_entity)
          end

          forecasting_days = params[:forecasting_days].to_i

          if forecasting_days <= 0
            return render_error("Forecasting days must be a positive integer")
          end

          ActiveRecord::Base.transaction do
            @company.update!(forecasting_days: forecasting_days)
            complete_step!
          end
        end

        private

        def step_name
          "forecasting_period"
        end

        def after_complete
          RecalculateRestockingJob.perform_later(@company.id, "forecasting_days")
        end
      end
    end
  end
end
