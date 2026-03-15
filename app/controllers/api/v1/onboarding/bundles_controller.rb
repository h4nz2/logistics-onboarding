module Api
  module V1
    module Onboarding
      class BundlesController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "bundles"
        end
      end
    end
  end
end
