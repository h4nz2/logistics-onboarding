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

      def show
        vendor = @company.vendors.find(params[:id])
        render json: {
          vendor: { id: vendor.id, name: vendor.name, product_ids: vendor.product_ids }
        }
      rescue ActiveRecord::RecordNotFound
        render_error("Vendor not found", status: :not_found)
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

      def update
        vendor = @company.vendors.find(params[:id])
        if vendor.update(vendor_params)
          render json: {
            vendor: { id: vendor.id, name: vendor.name, product_ids: vendor.product_ids }
          }
        else
          render_error(vendor.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_error("Vendor not found", status: :not_found)
      end

      def destroy
        vendor = @company.vendors.find(params[:id])
        vendor.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render_error("Vendor not found", status: :not_found)
      end

      private

      def vendor_params
        params.require(:vendor).permit(:name)
      end
    end
  end
end
