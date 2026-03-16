require "rails_helper"

RSpec.describe "Api::V1::Integrations", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/integrations" do
    it "returns integrations and available providers" do
      get "/api/v1/integrations"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["integrations"]).to be_an(Array)
      expect(json["available_providers"]).to include("shopify")
    end
  end

  describe "POST /api/v1/integrations" do
    it "creates an integration" do
      post "/api/v1/integrations", params: {
        integration: { provider: "shopify", configuration: { api_key: "abc" } }
      }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["integration"]["provider"]).to eq("shopify")
    end
  end

  describe "PATCH /api/v1/integrations/:id" do
    it "updates an integration" do
      integration = company.integrations.create!(provider: "shopify", configuration: {})

      patch "/api/v1/integrations/#{integration.id}", params: {
        integration: { configuration: { api_key: "new_key" } }
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["integration"]["configuration"]["api_key"]).to eq("new_key")
    end
  end

  describe "DELETE /api/v1/integrations/:id" do
    it "deletes an integration" do
      integration = company.integrations.create!(provider: "shopify", configuration: {})

      delete "/api/v1/integrations/#{integration.id}"

      expect(response).to have_http_status(:no_content)
    end
  end
end
