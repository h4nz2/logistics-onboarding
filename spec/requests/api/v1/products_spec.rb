require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "GET /api/v1/products" do
    it "returns a list of products" do
      company.products.create!(name: "Product A")

      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["products"].size).to eq(1)
    end
  end

  describe "GET /api/v1/products/:id" do
    it "returns a single product" do
      product = company.products.create!(name: "Product A")

      get "/api/v1/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["product"]["name"]).to eq("Product A")
    end
  end

  describe "POST /api/v1/products" do
    it "creates a product" do
      post "/api/v1/products", params: { product: { name: "New Product" } }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["product"]["name"]).to eq("New Product")
    end
  end

  describe "PATCH /api/v1/products/:id" do
    it "updates a product" do
      product = company.products.create!(name: "Old Name")

      patch "/api/v1/products/#{product.id}", params: { product: { name: "New Name" } }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["product"]["name"]).to eq("New Name")
    end
  end

  describe "DELETE /api/v1/products/:id" do
    it "deletes a product" do
      product = company.products.create!(name: "Product A")

      delete "/api/v1/products/#{product.id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "PATCH /api/v1/products/assign_vendors" do
    it "assigns vendors to products" do
      product = company.products.create!(name: "Product A")
      vendor = company.vendors.create!(name: "Vendor A")

      patch "/api/v1/products/assign_vendors", params: {
        assignments: [{ product_id: product.id, vendor_ids: [ vendor.id ] }]
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["products"].first["vendor_ids"]).to include(vendor.id)
    end
  end
end
