class FlowDefinitionPublisher
  Result = Struct.new(:success?, :flow_definition, :errors, keyword_init: true)

  def initialize(flow_definition, validator: FlowDefinitionValidator.new)
    @flow_definition = flow_definition
    @validator = validator
  end

  def publish
    errors = @validator.validate(@flow_definition.definition_payload)
    if errors.any?
      FlowDefinitionAuditEvent.create!(
        flow_definition: @flow_definition,
        verification_objective: @flow_definition.verification_objective,
        event_type: "validation_failed",
        payload: { errors: errors.map { |error| { path: error.path, message: error.message } } }
      )
      return Result.new(success?: false, flow_definition: @flow_definition, errors: errors)
    end

    FlowDefinition.transaction do
      objective = @flow_definition.verification_objective
      current_active = objective.flow_definitions.active.lock.first
      current_active&.update!(status: :deprecated)

      @flow_definition.update!(
        version: next_version(objective),
        status: :active,
        published_at: Time.current
      )

      FlowDefinitionAuditEvent.create!(
        flow_definition: @flow_definition,
        verification_objective: objective,
        event_type: "published",
        payload: {
          previous_active_flow_definition_id: current_active&.id,
          new_version: @flow_definition.version
        }
      )
    end

    Result.new(success?: true, flow_definition: @flow_definition, errors: [])
  end

  private

  def next_version(objective)
    objective.flow_definitions.maximum(:version).to_i + 1
  end
end
