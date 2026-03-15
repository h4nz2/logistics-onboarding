class Bundle < ApplicationRecord
  belongs_to :company
  has_and_belongs_to_many :products

  validates :name, presence: true
end
