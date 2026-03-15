class Integration < ApplicationRecord
  PROVIDERS = %w[
    shopify
    woocommerce
    amazon
  ].freeze

  belongs_to :company

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :provider, uniqueness: { scope: :company_id }
end
