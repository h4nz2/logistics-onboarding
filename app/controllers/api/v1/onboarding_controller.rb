module Api
  module V1
    class OnboardingController < BaseController
      STEP_CONFIG = {
        "welcome" => { mandatory: false },
        "lead_time" => { mandatory: true },
        "stock_days" => { mandatory: true },
        "forecasting_period" => { mandatory: true },
        "upload_pos" => { mandatory: false },
        "match_suppliers" => { mandatory: false },
        "bundles" => { mandatory: false },
        "integrations" => { mandatory: false }
      }.freeze

      def show
        steps = build_steps
        current_step = steps.find { |s| s[:status] == "pending" && !s[:locked] }

        completed = steps.all? { |s| s[:status].in?(%w[completed skipped]) }

        render json: {
          company: company_json,
          onboarding: {
            completed: completed,
            current_step: current_step&.dig(:name),
            steps: steps
          }
        }
      end

      private

      def build_steps
        onboarding_steps = @company.onboarding_steps.index_by(&:step)

        Company::ONBOARDING_STEPS.each_with_index.map do |step_name, position|
          record = onboarding_steps[step_name]
          config = STEP_CONFIG[step_name]
          locked = step_locked?(step_name)

          {
            name: step_name,
            position: position,
            status: record&.status || "pending",
            mandatory: config[:mandatory],
            locked: locked,
            lock_reason: locked ? lock_reason(step_name) : nil
          }
        end
      end

      def step_locked?(step_name)
        case step_name
        when "upload_pos"
          !@company.vendors.exists?
        else
          false
        end
      end

      def lock_reason(step_name)
        case step_name
        when "upload_pos"
          "Requires vendors to be added first"
        end
      end

      def company_json
        {
          id: @company.id,
          name: @company.name,
          lead_days: @company.lead_days,
          stock_days: @company.stock_days,
          forecasting_days: @company.forecasting_days
        }
      end
    end
  end
end
