module Api
  module V1
    module Onboarding
      class ForecastingPeriodController < BaseStepController
        def update
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

        def mandatory?
          true
        end
      end
    end
  end
end
