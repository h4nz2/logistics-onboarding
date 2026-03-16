require "rails_helper"

RSpec.describe "Api::V1::Vendors", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/vendors" do
    it "returns a list of vendors" do
      company.vendors.create!(name: "Vendor A")

      get "/api/v1/vendors"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["vendors"].size).to eq(1)
    end
  end

  describe "GET /api/v1/vendors/:id" do
    it "returns a single vendor" do
      vendor = company.vendors.create!(name: "Vendor A")

      get "/api/v1/vendors/#{vendor.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["vendor"]["name"]).to eq("Vendor A")
    end
  end

  describe "POST /api/v1/vendors" do
    it "creates a vendor" do
      post "/api/v1/vendors", params: { vendor: { name: "New Vendor" } }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["vendor"]["name"]).to eq("New Vendor")
    end
  end

  describe "PATCH /api/v1/vendors/:id" do
    it "updates a vendor" do
      vendor = company.vendors.create!(name: "Old Name")

      patch "/api/v1/vendors/#{vendor.id}", params: { vendor: { name: "New Name" } }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["vendor"]["name"]).to eq("New Name")
    end
  end

  describe "DELETE /api/v1/vendors/:id" do
    it "deletes a vendor" do
      vendor = company.vendors.create!(name: "Vendor A")

      delete "/api/v1/vendors/#{vendor.id}"

      expect(response).to have_http_status(:no_content)
    end
  end
end
