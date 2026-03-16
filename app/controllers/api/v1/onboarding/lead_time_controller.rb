module Api
  module V1
    module Onboarding
      class LeadTimeController < BaseStepController
        def update
          unless params.key?(:lead_days)
            return render_error("lead_days is required", status: :unprocessable_entity)
          end

          lead_days = params[:lead_days].to_i

          if lead_days <= 0
            return render_error("Lead days must be a positive integer")
          end

          ActiveRecord::Base.transaction do
            @company.update!(lead_days: lead_days)
            complete_step!
          end
        end

        private

        def step_name
          "lead_time"
        end
      end
    end
  end
end
