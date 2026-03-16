module Api
  module V1
    module Onboarding
      class MatchSuppliersController < BaseStepController
        def update
          if params[:assignments].present?
            return unless assign_vendors_to_products!
          end

          complete_step!
        end

        private

        def step_name
          "match_suppliers"
        end

        def assign_vendors_to_products!
          ActiveRecord::Base.transaction do
            params[:assignments].each do |assignment|
              product = @company.products.find(assignment[:product_id])
              vendors = @company.vendors.where(id: assignment[:vendor_ids])

              if vendors.size != assignment[:vendor_ids].size
                raise ActiveRecord::RecordNotFound, "Some vendor IDs do not belong to this company"
              end

              product.vendors = vendors
            end
          end
          true
        rescue ActiveRecord::RecordNotFound => e
          render_error(e.message, status: :not_found)
          false
        end
      end
    end
  end
end
