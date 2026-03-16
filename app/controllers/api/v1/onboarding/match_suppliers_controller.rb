module Api
  module V1
    module Onboarding
      class MatchSuppliersController < BaseStepController
        def update
          # TODO: Consider whether partial assignments should be allowed
          # (e.g. only some products have vendors assigned)
          unless @company.products.joins(:vendors).exists?
            return render_error(
              "At least one product must have a vendor assigned. Use PATCH /api/v1/products/assign_vendors to assign vendors to products.",
              status: :unprocessable_entity
            )
          end

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
