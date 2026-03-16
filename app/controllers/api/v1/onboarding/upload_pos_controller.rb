module Api
  module V1
    module Onboarding
      class UploadPosController < BaseStepController
        def update
          complete_step!
        end

        private

        def step_name
          "upload_pos"
        end

        def step_locked?
          !@company.vendors.exists?
        end

        def lock_reason
          "Complete 'Add Vendors' to unlock this step"
        end
      end
    end
  end
end
