module Api
  module V1
    class BaseController < ApplicationController
      # TODO: load company from current user once authentication is implemented
      before_action :set_company

      private

      def set_company
        @company = Company.first
      end

      def render_error(messages, status: :unprocessable_entity)
        render json: { errors: Array(messages) }, status: status
      end
    end
  end
end
