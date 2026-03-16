module Api
  module V1
    module Onboarding
      class SyncProgressController < BaseController
        FETCHERS = {
          products: ProductFetcher,
          warehouses: WarehouseFetcher
        }.freeze

        def show
          resources = FETCHERS.transform_values do |klass|
            klass.new(@company).progress
          end

          render json: {
            sync_progress: {
              status: compute_status(resources),
              resources: resources
            }
          }
        end

        private

        def compute_status(resources)
          totals = resources.values
          return "pending" if totals.all? { |r| r[:total].zero? }
          return "completed" if totals.all? { |r| r[:total].positive? && r[:fetched] == r[:total] }

          "in_progress"
        end
      end
    end
  end
end
