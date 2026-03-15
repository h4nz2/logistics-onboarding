class OnboardingFileUpload < ApplicationRecord
  belongs_to :company

  has_one_attached :file

  validates :step, presence: true
  validates :processing_status, presence: true
  validates :file, presence: true
end
