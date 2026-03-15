class SalesHistory < ApplicationRecord
  belongs_to :product

  validates :date, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
