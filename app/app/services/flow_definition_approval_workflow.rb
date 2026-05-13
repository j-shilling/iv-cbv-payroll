class FlowDefinitionApprovalWorkflow
  Result = Struct.new(:success?, :errors, keyword_init: true)

  REQUIRED_ROLES = %w[product policy].freeze

  def initialize(flow_definition, approvals:)
    @flow_definition = flow_definition
    @approvals = approvals || {}
  end

  def validate_and_record!
    missing_roles = REQUIRED_ROLES.reject { |role| approved?(role) }
    if missing_roles.any?
      return Result.new(success?: false, errors: ["Missing approvals: #{missing_roles.join(', ')}"])
    end

    FlowDefinitionAuditEvent.create!(
      flow_definition: @flow_definition,
      verification_objective: @flow_definition.verification_objective,
      event_type: "approval_recorded",
      payload: { approvals: @approvals }
    )

    Result.new(success?: true, errors: [])
  end

  private

  def approved?(role)
    data = @approvals[role]
    data.is_a?(Hash) && data["approved_by"].present? && data["approved_at"].present?
  end
end
