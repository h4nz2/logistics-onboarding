require "rails_helper"

RSpec.describe "Api::V1::Onboarding", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/onboarding" do
    it "returns onboarding status" do
      get "/api/v1/onboarding"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["company"]["name"]).to eq("Test Co")
      expect(json["onboarding"]["steps"].size).to eq(10)
      expect(json["onboarding"]["completed"]).to be false
    end
  end
end
