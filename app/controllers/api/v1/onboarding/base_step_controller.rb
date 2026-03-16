module Api
  module V1
    module Onboarding
      class BaseStepController < BaseController
        before_action :check_step_locked, only: :update
        before_action :check_file_upload_required, only: :update

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

        def reopen
          onboarding_step = @company.onboarding_steps.find_by(step: step_name)

          unless onboarding_step&.status.in?(%w[completed skipped])
            return render_error("Step is not completed or skipped", status: :unprocessable_entity)
          end

          onboarding_step.status = :pending

          if onboarding_step.save
            render json: {
              step: { name: step_name, status: "pending" },
              company: company_json
            }
          else
            render_error(onboarding_step.errors.full_messages)
          end
        end

        private

        def step_name
          raise NotImplementedError, "Subclasses must define step_name"
        end

        def step_config
          Company::ONBOARDING_STEP_CONFIG[step_name] || {}
        end

        def mandatory?
          step_config[:mandatory] || false
        end

        def step_locked?
          false
        end

        def lock_reason
          nil
        end

        def requires_file_upload?
          step_config[:requires_file_upload] || false
        end

        def check_step_locked
          if step_locked?
            render json: { error: "Step is locked", lock_reason: lock_reason }, status: :unprocessable_entity
          end
        end

        def check_file_upload_required
          return unless requires_file_upload?

          unless @company.onboarding_file_uploads.where(step: step_name).exists?
            render_error("File must be uploaded before completing this step. Use POST /api/v1/onboarding/file_uploads to upload.", status: :unprocessable_entity)
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
