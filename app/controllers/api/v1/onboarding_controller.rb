module Api
  module V1
    class OnboardingController < BaseController
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
        file_uploads = @company.onboarding_file_uploads.index_by(&:step)

        Company::ONBOARDING_STEPS.each_with_index.map do |step_name, position|
          record = onboarding_steps[step_name]
          config = Company::ONBOARDING_STEP_CONFIG[step_name]
          locked = step_locked?(step_name)

          step_data = {
            name: step_name,
            position: position,
            status: record&.status || "pending",
            mandatory: config[:mandatory],
            locked: locked,
            lock_reason: locked ? lock_reason(step_name) : nil,
            unlock_steps: locked ? unlock_steps(step_name, onboarding_steps) : nil
          }

          if config[:requires_file_upload]
            upload = file_uploads[step_name]
            step_data[:file_upload] = upload ? file_upload_json(upload) : nil
          end

          step_data
        end
      end

      def step_locked?(step_name)
        case step_name
        when "upload_pos"
          !@company.vendors.exists?
        when "match_suppliers"
          !@company.vendors.exists? || !@company.products.exists?
        else
          false
        end
      end

      def lock_reason(step_name)
        case step_name
        when "upload_pos"
          "Complete 'Add Vendors' to unlock this step"
        when "match_suppliers"
          missing = []
          missing << "'Add Vendors'" unless @company.vendors.exists?
          missing << "'Add Products'" unless @company.products.exists?
          "Complete #{missing.join(' and ')} to unlock this step"
        end
      end

      def unlock_steps(step_name, onboarding_steps)
        required = case step_name
                   when "upload_pos"
                     @company.vendors.exists? ? [] : ["add_vendors"]
                   when "match_suppliers"
                     steps = []
                     steps << "add_vendors" unless @company.vendors.exists?
                     steps << "add_products" unless @company.products.exists?
                     steps
                   else
                     []
                   end

        required.map do |name|
          record = onboarding_steps[name]
          { name: name, status: record&.status || "pending" }
        end
      end

      def file_upload_json(upload)
        {
          id: upload.id,
          processing_status: upload.processing_status,
          error_message: upload.error_message,
          created_at: upload.created_at
        }
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
