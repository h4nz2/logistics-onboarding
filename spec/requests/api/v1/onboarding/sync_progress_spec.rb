require "rails_helper"

RSpec.describe "Api::V1::Onboarding::SyncProgress", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/onboarding/sync_progress" do
    it "returns sync progress for all resources" do
      get "/api/v1/onboarding/sync_progress"

      expect(response).to have_http_status(:ok)

      body = response.parsed_body
      expect(body["sync_progress"]["status"]).to eq("pending")
      expect(body["sync_progress"]["resources"]["products"]).to eq("total" => 0, "fetched" => 0)
      expect(body["sync_progress"]["resources"]["warehouses"]).to eq("total" => 0, "fetched" => 0)
    end

    it "returns in_progress when a fetcher reports partial progress" do
      allow_any_instance_of(ProductFetcher).to receive(:progress).and_return(total: 10, fetched: 3)

      get "/api/v1/onboarding/sync_progress"

      body = response.parsed_body
      expect(body["sync_progress"]["status"]).to eq("in_progress")
      expect(body["sync_progress"]["resources"]["products"]).to eq("total" => 10, "fetched" => 3)
    end

    it "returns completed when all fetchers are done" do
      allow_any_instance_of(ProductFetcher).to receive(:progress).and_return(total: 10, fetched: 10)
      allow_any_instance_of(WarehouseFetcher).to receive(:progress).and_return(total: 5, fetched: 5)

      get "/api/v1/onboarding/sync_progress"

      body = response.parsed_body
      expect(body["sync_progress"]["status"]).to eq("completed")
    end
  end
end
