module Api
  module V1
    module Onboarding
      class SetIntegrationsController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "set_integrations"
        end
      end
    end
  end
end
