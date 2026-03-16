module Api
  module V1
    module Onboarding
      class AddVendorsController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "add_vendors"
        end
      end
    end
  end
end
