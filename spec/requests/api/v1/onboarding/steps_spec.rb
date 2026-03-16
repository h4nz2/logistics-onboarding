require "rails_helper"

RSpec.describe "Api::V1::Onboarding Steps", type: :request do
  let!(:company) { Company.create!(name: "Test Co") }

  describe "PATCH /api/v1/onboarding/welcome" do
    it "completes the welcome step" do
      patch "/api/v1/onboarding/welcome"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
    end
  end

  describe "PATCH /api/v1/onboarding/lead_time" do
    it "sets lead time and completes the step" do
      patch "/api/v1/onboarding/lead_time", params: { lead_days: 7 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
      expect(response.parsed_body["company"]["lead_days"]).to eq(7)
    end

    it "enqueues a recalculation job" do
      expect {
        patch "/api/v1/onboarding/lead_time", params: { lead_days: 7 }
      }.to have_enqueued_job(RecalculateRestockingJob).with(company.id, "lead_days")
    end
  end

  describe "PATCH /api/v1/onboarding/stock_days" do
    it "sets stock days and completes the step" do
      patch "/api/v1/onboarding/stock_days", params: { stock_days: 30 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
      expect(response.parsed_body["company"]["stock_days"]).to eq(30)
    end

    it "enqueues a recalculation job" do
      expect {
        patch "/api/v1/onboarding/stock_days", params: { stock_days: 30 }
      }.to have_enqueued_job(RecalculateRestockingJob).with(company.id, "stock_days")
    end
  end

  describe "PATCH /api/v1/onboarding/forecasting_period" do
    it "sets forecasting period and completes the step" do
      patch "/api/v1/onboarding/forecasting_period", params: { forecasting_days: 90 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
      expect(response.parsed_body["company"]["forecasting_days"]).to eq(90)
    end

    it "enqueues a recalculation job" do
      expect {
        patch "/api/v1/onboarding/forecasting_period", params: { forecasting_days: 90 }
      }.to have_enqueued_job(RecalculateRestockingJob).with(company.id, "forecasting_days")
    end
  end

  describe "PATCH /api/v1/onboarding/add_vendors" do
    it "completes the add vendors step" do
      patch "/api/v1/onboarding/add_vendors"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
    end
  end

  describe "PATCH /api/v1/onboarding/add_products" do
    it "completes the add products step" do
      patch "/api/v1/onboarding/add_products"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
    end
  end

  describe "PATCH /api/v1/onboarding/set_integrations" do
    it "completes the set integrations step" do
      patch "/api/v1/onboarding/set_integrations"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("completed")
    end
  end

  describe "skip and reopen" do
    it "skips an optional step" do
      patch "/api/v1/onboarding/add_vendors/skip"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("skipped")
    end

    it "reopens a completed step" do
      patch "/api/v1/onboarding/welcome"
      patch "/api/v1/onboarding/welcome/reopen"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["step"]["status"]).to eq("pending")
    end
  end
end
