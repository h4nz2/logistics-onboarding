module Api
  module V1
    module Onboarding
      class StockDaysController < BaseStepController
        def update
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

        def mandatory?
          true
        end
      end
    end
  end
end
