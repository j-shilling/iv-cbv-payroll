class VerificationRequestCreator
  Result = Struct.new(:success?, :verification_request, :errors, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(cbv_applicant:, objective_key:, case_identifier:, due_date: nil, reminder_cadence: nil, note: nil)
    @cbv_applicant = cbv_applicant
    @objective_key = objective_key
    @case_identifier = case_identifier
    @due_date = due_date
    @reminder_cadence = reminder_cadence
    @note = note
  end

  def call
    objective = VerificationObjective.where(objective_key: @objective_key).order(version: :desc).first
    return Result.new(success?: false, errors: ["Objective not found"]) unless objective

    flow_definition = objective.flow_definitions.active.order(version: :desc).first
    return Result.new(success?: false, errors: ["No active definition for objective"]) unless flow_definition

    verification_request = VerificationRequest.new(
      cbv_applicant: @cbv_applicant,
      verification_objective: objective,
      flow_definition: flow_definition,
      case_identifier: @case_identifier,
      requested_at: Time.current,
      definition_snapshot: flow_definition.definition_payload,
      due_date: @due_date,
      reminder_cadence: @reminder_cadence,
      note: @note,
      status: :created
    )

    if verification_request.save
      Result.new(success?: true, verification_request: verification_request, errors: [])
    else
      Result.new(success?: false, verification_request: verification_request, errors: verification_request.errors.full_messages)
    end
  end
end
