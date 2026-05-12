require "rails_helper"

RSpec.describe VerificationEvent, type: :model do
  it "is append-only" do
    objective = create(:verification_objective)
    definition = create(:flow_definition, verification_objective: objective)
    request = VerificationRequest.create!(
      case_identifier: "CASE-123",
      cbv_applicant: create(:cbv_applicant),
      verification_objective: objective,
      flow_definition: definition,
      requested_at: Time.current,
      definition_snapshot: definition.definition_payload
    )

    event = request.verification_events.create!(
      event_type: "request_created",
      payload: { "foo" => "bar" },
      occurred_at: Time.current
    )

    expect(event.update(payload: { "foo" => "baz" })).to be(false)
    expect(event.destroy).to be(false)
  end
end
