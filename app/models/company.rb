class Company < ApplicationRecord
  ONBOARDING_STEP_CONFIG = {
    "welcome" => { mandatory: false },
    "lead_time" => { mandatory: true },
    "stock_days" => { mandatory: true },
    "forecasting_period" => { mandatory: true },
    "add_vendors" => { mandatory: false },
    "add_products" => { mandatory: false },
    "upload_pos" => { mandatory: false, requires_file_upload: true },
    "match_suppliers" => { mandatory: false },
    "bundles" => { mandatory: false, requires_file_upload: true },
    "set_integrations" => { mandatory: false }
  }.freeze

  ONBOARDING_STEPS = ONBOARDING_STEP_CONFIG.keys.freeze

  has_many :onboarding_steps, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :integration_requests, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :purchase_orders, through: :vendors
  has_many :onboarding_file_uploads, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :bundles, dependent: :destroy

  validates :name, presence: true
end
