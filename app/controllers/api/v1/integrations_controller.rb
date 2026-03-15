module Api
  module V1
    class IntegrationsController < BaseController
      def index
        integrations = @company.integrations
        used_providers = integrations.pluck(:provider)
        available_providers = Integration::PROVIDERS - used_providers

        render json: {
          integrations: integrations.map { |i| integration_json(i) },
          available_providers: available_providers
        }
      end

      def create
        integration = @company.integrations.build(integration_params)

        if integration.save
          render json: { integration: integration_json(integration) }, status: :created
        else
          render_error(integration.errors.full_messages)
        end
      end

      def update
        integration = @company.integrations.find(params[:id])
        if integration.update(integration_params)
          render json: { integration: integration_json(integration) }
        else
          render_error(integration.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_error("Integration not found", status: :not_found)
      end

      def destroy
        integration = @company.integrations.find(params[:id])
        integration.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render_error("Integration not found", status: :not_found)
      end

      private

      def integration_params
        params.require(:integration).permit(:provider, configuration: {})
      end

      def integration_json(integration)
        {
          id: integration.id,
          provider: integration.provider,
          configuration: integration.configuration
        }
      end
    end
  end
end
