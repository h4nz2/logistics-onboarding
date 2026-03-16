require "rails_helper"

RSpec.describe "Api::V1::Onboarding::FileUploads", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "POST /api/v1/onboarding/file_uploads" do
    it "uploads a file for a step" do
      file = Rack::Test::UploadedFile.new(
        StringIO.new("sku,name\nABC,Widget"),
        "text/csv",
        original_filename: "products.csv"
      )

      post "/api/v1/onboarding/file_uploads", params: { step: "upload_pos", file: file }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["file_upload"]["step"]).to eq("upload_pos")
      expect(response.parsed_body["file_upload"]["processing_status"]).to eq("pending")
    end
  end

  describe "GET /api/v1/onboarding/file_uploads/:id" do
    it "returns a file upload status" do
      upload = company.onboarding_file_uploads.new(step: "upload_pos", processing_status: "pending")
      upload.file.attach(io: StringIO.new("data"), filename: "test.csv", content_type: "text/csv")
      upload.save!

      get "/api/v1/onboarding/file_uploads/#{upload.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["file_upload"]["id"]).to eq(upload.id)
    end
  end
end
