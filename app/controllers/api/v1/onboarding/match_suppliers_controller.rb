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

        def step_locked?
          !@company.vendors.exists? || !@company.products.exists?
        end

        def lock_reason
          missing = []
          missing << "'Add Vendors'" unless @company.vendors.exists?
          missing << "'Add Products'" unless @company.products.exists?
          "Complete #{missing.join(' and ')} to unlock this step"
        end
      end
    end
  end
end
