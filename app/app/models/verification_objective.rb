class VerificationObjective < ApplicationRecord
  has_many :flow_definitions, dependent: :destroy
  has_many :verification_requests, dependent: :restrict_with_error

  validates :objective_key, :version, :name, presence: true
  validates :version, numericality: { only_integer: true, greater_than: 0 }
  validates :objective_key, uniqueness: { scope: :version }
end
