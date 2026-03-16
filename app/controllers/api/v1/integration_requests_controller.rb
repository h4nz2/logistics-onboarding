module Api
  module V1
    class IntegrationRequestsController < BaseController
      def create
        request = @company.integration_requests.build(integration_request_params)

        if request.save
          render json: { integration_request: integration_request_json(request) }, status: :created
        else
          render_error(request.errors.full_messages)
        end
      end

      def index
        requests = @company.integration_requests

        render json: {
          integration_requests: requests.map { |r| integration_request_json(r) }
        }
      end

      private

      def integration_request_params
        params.require(:integration_request).permit(:name, :description)
      end

      def integration_request_json(request)
        {
          id: request.id,
          name: request.name,
          description: request.description,
          created_at: request.created_at
        }
      end
    end
  end
end
