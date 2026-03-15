class OnboardingStep < ApplicationRecord
  belongs_to :company

  enum :step, Company::ONBOARDING_STEPS.each_with_index.to_h { |step, i| [step.to_sym, i] }
  enum :status, { pending: 0, completed: 1, skipped: 2 }, default: :pending

  validates :step, presence: true, uniqueness: { scope: :company_id }
  validates :status, presence: true
end
