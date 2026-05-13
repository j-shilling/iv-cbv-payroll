# frozen_string_literal: true

if StudentEnrollmentVerificationDefinition.enabled?
  objective = VerificationObjective.find_or_create_by!(
    objective_key: StudentEnrollmentVerificationDefinition::OBJECTIVE_KEY,
    version: 1
  ) do |record|
    record.name = "Student enrollment verification"
    record.description = "Collect attestation, school details, and evidence"
    record.metadata = { "pilot" => "internal_users" }
  end

  flow_definition = FlowDefinition.find_or_create_by!(
    verification_objective: objective,
    version: 1,
    status: :draft
  ) do |record|
    record.definition_payload = StudentEnrollmentVerificationDefinition.payload
  end

  FlowDefinitionPublisher.new(flow_definition).publish
end
