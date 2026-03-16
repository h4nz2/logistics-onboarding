module Api
  module V1
    class ProductsController < BaseController
      def index
        products = @company.products.includes(:vendors)

        render json: {
          products: products.map { |p|
            { id: p.id, name: p.name, vendor_ids: p.vendor_ids }
          }
        }
      end

      def show
        product = @company.products.find(params[:id])
        render json: {
          product: { id: product.id, name: product.name, vendor_ids: product.vendor_ids }
        }
      rescue ActiveRecord::RecordNotFound
        render_error("Product not found", status: :not_found)
      end

      def create
        product = @company.products.build(product_params)

        if product.save
          render json: {
            product: { id: product.id, name: product.name, vendor_ids: [] }
          }, status: :created
        else
          render_error(product.errors.full_messages)
        end
      end

      def update
        product = @company.products.find(params[:id])
        if product.update(product_params)
          render json: {
            product: { id: product.id, name: product.name, vendor_ids: product.vendor_ids }
          }
        else
          render_error(product.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_error("Product not found", status: :not_found)
      end

      def destroy
        product = @company.products.find(params[:id])
        product.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render_error("Product not found", status: :not_found)
      end

      def assign_vendors
        assignments = params.require(:assignments)

        ActiveRecord::Base.transaction do
          assignments.each do |assignment|
            product = @company.products.find(assignment[:product_id])
            vendors = @company.vendors.where(id: assignment[:vendor_ids])

            if vendors.size != assignment[:vendor_ids].size
              raise ActiveRecord::RecordNotFound, "Some vendor IDs do not belong to this company"
            end

            product.vendors = vendors
          end
        end

        products = @company.products.includes(:vendors)
        render json: {
          products: products.map { |p|
            { id: p.id, name: p.name, vendor_ids: p.vendor_ids }
          }
        }
      rescue ActiveRecord::RecordNotFound => e
        render_error(e.message, status: :not_found)
      end

      private

      def product_params
        params.require(:product).permit(:name)
      end
    end
  end
end
