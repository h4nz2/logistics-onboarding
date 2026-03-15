class Company < ApplicationRecord
  has_many :integrations, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :purchase_orders, through: :vendors
  has_many :onboarding_file_uploads, dependent: :destroy

  validates :name, presence: true
end
