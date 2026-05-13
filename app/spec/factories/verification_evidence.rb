FactoryBot.define do
  factory :verification_evidence do
    verification_request
    verification_step
    evidence_type { "enrollment_document" }
    payload { { "filename" => "enrollment.pdf" } }
    collected_at { Time.current }
  end
end
