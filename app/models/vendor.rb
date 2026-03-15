class Vendor < ApplicationRecord
  belongs_to :company

  has_many :purchase_orders, dependent: :destroy
  has_and_belongs_to_many :products

  validates :name, presence: true
end
