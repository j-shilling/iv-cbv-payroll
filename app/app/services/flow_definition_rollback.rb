class FlowDefinitionRollback
  Result = Struct.new(:success?, :flow_definition, :errors, keyword_init: true)

  def initialize(verification_objective)
    @verification_objective = verification_objective
  end

  def rollback!
    candidates = @verification_objective.flow_definitions.order(version: :desc)
    current = candidates.find(&:active?)
    target = candidates.detect { |flow| flow.deprecated? }
    return Result.new(success?: false, errors: ["No deprecated definition to roll back to"]) unless target

    FlowDefinition.transaction do
      current&.update!(status: :deprecated)
      target.update!(status: :active, published_at: Time.current)

      FlowDefinitionAuditEvent.create!(
        flow_definition: target,
        verification_objective: @verification_objective,
        event_type: "rollback_published",
        payload: { rolled_back_from_id: current&.id, rolled_back_to_id: target.id }
      )
    end

    Result.new(success?: true, flow_definition: target, errors: [])
  end
end
