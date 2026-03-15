class Product < ApplicationRecord
  has_and_belongs_to_many :vendors
  has_and_belongs_to_many :bundles
  has_many :purchase_order_items, dependent: :destroy
  has_many :sales_histories, dependent: :destroy

  validates :name, presence: true
end
