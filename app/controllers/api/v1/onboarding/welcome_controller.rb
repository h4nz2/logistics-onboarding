module Api
  module V1
    module Onboarding
      class WelcomeController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "welcome"
        end
      end
    end
  end
end
