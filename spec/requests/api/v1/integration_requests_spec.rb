require "rails_helper"

RSpec.describe "Api::V1::IntegrationRequests", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/integration_requests" do
    it "returns a list of integration requests" do
      company.integration_requests.create!(name: "Magento")

      get "/api/v1/integration_requests"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["integration_requests"].size).to eq(1)
    end
  end

  describe "POST /api/v1/integration_requests" do
    it "creates an integration request" do
      post "/api/v1/integration_requests", params: {
        integration_request: { name: "Magento", description: "Please add Magento support" }
      }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["integration_request"]["name"]).to eq("Magento")
    end
  end
end
