class VerificationEvidence < ApplicationRecord
  belongs_to :verification_request
  belongs_to :verification_step, optional: true

  validates :evidence_type, :payload, :collected_at, presence: true
end
