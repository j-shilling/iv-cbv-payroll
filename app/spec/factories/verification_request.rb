FactoryBot.define do
  factory :verification_request do
    case_identifier { "CASE-123" }
    cbv_applicant
    verification_objective
    flow_definition { association(:flow_definition, verification_objective: verification_objective) }
    requested_at { Time.current }
    definition_snapshot { flow_definition.definition_payload }
    status { :created }


    trait :completed do
      status { :completed }
      completed_at { requested_at + 2.hours }
    end

    trait :expired do
      status { :expired }
    end
  end
end
