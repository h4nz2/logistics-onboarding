module Api
  module V1
    module Onboarding
      class FileUploadsController < BaseController
        ALLOWED_STEPS = %w[upload_pos bundles].freeze

        ALLOWED_CONTENT_TYPES = %w[
          text/csv
          application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
          application/vnd.ms-excel
        ].freeze

        STEP_JOBS = {
          "upload_pos" => PurchaseOrderImportJob,
          "bundles" => BundleImportJob
        }.freeze

        def create
          step = params[:step]

          unless step.in?(ALLOWED_STEPS)
            return render_error("Step must be one of: #{ALLOWED_STEPS.join(', ')}")
          end

          unless params[:file].present?
            return render_error("File is required", status: :unprocessable_entity)
          end

          unless params[:file].content_type.in?(ALLOWED_CONTENT_TYPES)
            return render_error("Invalid file type. Allowed types: CSV, XLS, XLSX", status: :unprocessable_entity)
          end

          existing_upload = @company.onboarding_file_uploads.find_by(step: step)
          existing_upload&.destroy

          upload = @company.onboarding_file_uploads.build(
            step: step,
            processing_status: "pending",
            file: params[:file]
          )

          unless upload.save
            return render_error(upload.errors.full_messages)
          end

          STEP_JOBS[step].perform_later(upload.id)

          render json: { file_upload: file_upload_json(upload) }, status: :created
        end

        def show
          upload = @company.onboarding_file_uploads.find(params[:id])
          render json: { file_upload: file_upload_json(upload) }
        rescue ActiveRecord::RecordNotFound
          render_error("File upload not found", status: :not_found)
        end

        private

        def file_upload_json(upload)
          {
            id: upload.id,
            step: upload.step,
            processing_status: upload.processing_status,
            error_message: upload.error_message,
            created_at: upload.created_at
          }
        end
      end
    end
  end
end
