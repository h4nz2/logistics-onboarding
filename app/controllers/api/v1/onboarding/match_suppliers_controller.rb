module Api
  module V1
    module Onboarding
      class MatchSuppliersController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "match_suppliers"
        end
      end
    end
  end
end
