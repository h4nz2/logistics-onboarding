module Api
  module V1
    module Onboarding
      class BaseStepController < BaseController
        before_action :check_step_locked

        def skip
          if mandatory?
            return render_error("This step cannot be skipped", status: :unprocessable_entity)
          end

          onboarding_step = @company.onboarding_steps.find_or_initialize_by(step: step_name)
          onboarding_step.status = :skipped

          if onboarding_step.save
            render json: { step: { name: step_name, status: "skipped" } }
          else
            render_error(onboarding_step.errors.full_messages)
          end
        end

        private

        def step_name
          raise NotImplementedError, "Subclasses must define step_name"
        end

        def mandatory?
          false
        end

        def step_locked?
          false
        end

        def lock_reason
          nil
        end

        def check_step_locked
          if step_locked?
            render json: { error: "Step is locked", lock_reason: lock_reason }, status: :unprocessable_entity
          end
        end

        def complete_step!
          onboarding_step = @company.onboarding_steps.find_or_initialize_by(step: step_name)
          onboarding_step.status = :completed

          if onboarding_step.save
            render json: {
              step: { name: step_name, status: "completed" },
              company: company_json
            }
          else
            render_error(onboarding_step.errors.full_messages)
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
end
