class OnboardingFileUpload < ApplicationRecord
  MAX_FILE_SIZE = 10.megabytes

  belongs_to :company

  has_one_attached :file

  validates :step, presence: true
  validates :processing_status, presence: true
  validates :file, presence: true
  validate :file_size_within_limit, if: -> { file.attached? }

  private

  def file_size_within_limit
    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "is too large (maximum is #{MAX_FILE_SIZE / 1.megabyte} MB)")
    end
  end
end
