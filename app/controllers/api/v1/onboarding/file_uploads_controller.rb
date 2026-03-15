module Api
  module V1
    module Onboarding
      class FileUploadsController < BaseController
        ALLOWED_STEPS = %w[upload_pos bundles].freeze

        def create
          step = params[:step]

          unless step.in?(ALLOWED_STEPS)
            return render_error("Step must be one of: #{ALLOWED_STEPS.join(', ')}")
          end

          upload = @company.onboarding_file_uploads.build(
            step: step,
            processing_status: "pending",
            file: params[:file]
          )

          if upload.save
            render json: { file_upload: file_upload_json(upload) }, status: :created
          else
            render_error(upload.errors.full_messages)
          end
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
            created_at: upload.created_at
          }
        end
      end
    end
  end
end
