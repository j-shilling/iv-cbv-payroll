class FlowDefinitionAuditEvent < ApplicationRecord
  belongs_to :flow_definition, optional: true
  belongs_to :verification_objective

  validates :event_type, presence: true
  validates :payload, presence: true
end
