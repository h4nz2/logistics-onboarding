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
          "Requires vendors to be added first"
        end
      end
    end
  end
end
