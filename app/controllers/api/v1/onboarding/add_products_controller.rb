module Api
  module V1
    module Onboarding
      class AddProductsController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "add_products"
        end
      end
    end
  end
end
