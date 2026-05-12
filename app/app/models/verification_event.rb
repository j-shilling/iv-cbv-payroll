class VerificationEvent < ApplicationRecord
  belongs_to :verification_request
  belongs_to :verification_step, optional: true

  validates :event_type, :payload, :occurred_at, presence: true

  before_update :prevent_update
  before_destroy :prevent_destroy

  private

  def prevent_update
    errors.add(:base, "Verification events are append-only")
    throw(:abort)
  end

  def prevent_destroy
    errors.add(:base, "Verification events are append-only")
    throw(:abort)
  end
end
