class Integration < ApplicationRecord
  belongs_to :company

  validates :provider, presence: true
  validates :provider, uniqueness: { scope: :company_id }
end
