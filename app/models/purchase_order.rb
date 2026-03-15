class PurchaseOrder < ApplicationRecord
  belongs_to :vendor

  has_one :company, through: :vendor

  has_many :purchase_order_items, dependent: :destroy

  validates :order_date, presence: true
end
