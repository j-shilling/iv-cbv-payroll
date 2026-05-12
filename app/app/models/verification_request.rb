class VerificationRequest < ApplicationRecord
  enum :status, {
    created: 0,
    sent: 1,
    in_progress: 2,
    completed: 3,
    expired: 4
  }, default: :created, validate: true

  belongs_to :cbv_applicant
  belongs_to :verification_objective
  belongs_to :flow_definition
  belongs_to :assigned_user, class_name: "User", optional: true

  has_many :verification_steps, dependent: :destroy
  has_many :verification_evidence, dependent: :destroy
  has_many :verification_events, dependent: :destroy

  validates :case_identifier, :requested_at, :definition_snapshot, presence: true
end
