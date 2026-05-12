FactoryBot.define do
  factory :verification_request do
    case_identifier { "CASE-123" }
    cbv_applicant
    verification_objective
    flow_definition { association(:flow_definition, verification_objective: verification_objective) }
    requested_at { Time.current }
    definition_snapshot { flow_definition.definition_payload }
    status { :created }
  end
end
