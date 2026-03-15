class Company < ApplicationRecord
  ONBOARDING_STEPS = %w[
    welcome
    lead_time
    stock_days
    forecasting_period
    upload_pos
    match_suppliers
    bundles
    integrations
  ].freeze

  has_many :onboarding_steps, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :purchase_orders, through: :vendors
  has_many :onboarding_file_uploads, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :bundles, dependent: :destroy

  validates :name, presence: true
end
