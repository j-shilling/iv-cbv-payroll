class VerificationRequest < ApplicationRecord
  enum :status, {
    pending: 0,
    in_progress: 1,
    fulfilled: 2,
    rejected: 3,
    cancelled: 4
  }, default: :pending, validate: true

  belongs_to :cbv_applicant
  belongs_to :verification_objective
  belongs_to :flow_definition
  belongs_to :assigned_user, class_name: "User", optional: true

  has_many :verification_steps, dependent: :destroy
  has_many :verification_evidence, dependent: :destroy
  has_many :verification_events, dependent: :destroy

  validates :case_identifier, :requested_at, :definition_snapshot, presence: true
end
