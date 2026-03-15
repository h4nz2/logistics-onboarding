module Api
  module V1
    class VendorsController < BaseController
      def index
        vendors = @company.vendors.includes(:products)

        render json: {
          vendors: vendors.map { |v|
            { id: v.id, name: v.name, product_ids: v.product_ids }
          }
        }
      end

      def create
        vendor = @company.vendors.build(vendor_params)

        if vendor.save
          render json: {
            vendor: { id: vendor.id, name: vendor.name, product_ids: [] }
          }, status: :created
        else
          render_error(vendor.errors.full_messages)
        end
      end

      private

      def vendor_params
        params.require(:vendor).permit(:name)
      end
    end
  end
end
