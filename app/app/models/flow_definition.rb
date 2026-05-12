class FlowDefinition < ApplicationRecord
  enum :status, {
    draft: 0,
    active: 1,
    deprecated: 2
  }, default: :draft, validate: true

  belongs_to :verification_objective
  has_many :verification_requests, dependent: :restrict_with_error

  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :definition_payload, presence: true
  validates :verification_objective_id, uniqueness: { scope: :version }

  before_validation :set_published_at
  after_create :record_draft_creation, if: :draft?
  before_update :prevent_mutation_when_active
  before_destroy :prevent_destroy_when_active

  private

  def set_published_at
    self.published_at ||= Time.current if active?
  end

  def prevent_mutation_when_active
    return unless active? && will_save_change_to_definition_payload?

    errors.add(:base, "Active flow definitions are immutable")
    throw(:abort)
  end

  def prevent_destroy_when_active
    return unless active?

    errors.add(:base, "Active flow definitions cannot be deleted")
    throw(:abort)
  end

  def record_draft_creation
    FlowDefinitionAuditEvent.create!(
      flow_definition: self,
      verification_objective:,
      event_type: "draft_created",
      payload: { version: version }
    )
  end
end
