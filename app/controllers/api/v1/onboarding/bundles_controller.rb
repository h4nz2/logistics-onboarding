module Api
  module V1
    module Onboarding
      class BundlesController < BaseStepController
        ALLOWED_CONTENT_TYPES = %w[
          text/csv
          application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
          application/vnd.ms-excel
        ].freeze

        def update
          unless params[:file].present?
            return render_error("File is required", status: :unprocessable_entity)
          end

          unless valid_content_type?
            return render_error(
              "Invalid file type. Allowed types: CSV, XLS, XLSX",
              status: :unprocessable_entity
            )
          end

          upload = @company.onboarding_file_uploads.build(
            step: step_name,
            processing_status: "pending",
            file: params[:file]
          )

          unless upload.save
            return render_error(upload.errors.full_messages)
          end

          BundleImportJob.perform_later(upload.id)

          complete_step!
        end

        private

        def step_name
          "bundles"
        end

        def valid_content_type?
          params[:file].content_type.in?(ALLOWED_CONTENT_TYPES)
        end
      end
    end
  end
end
