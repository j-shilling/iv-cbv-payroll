class VerificationStep < ApplicationRecord
  enum :status, {
    pending: 0,
    in_progress: 1,
    completed: 2,
    failed: 3,
    skipped: 4
  }, default: :pending, validate: true

  belongs_to :verification_request
  has_many :verification_evidence, dependent: :nullify
  has_many :verification_events, dependent: :nullify

  validates :step_key, :payload, presence: true
  validates :step_key, uniqueness: { scope: :verification_request_id }
end
