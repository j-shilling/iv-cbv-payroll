require "rails_helper"

RSpec.describe VerificationBranchDecisionRecorder do
  it "persists branch decision details into the event log" do
    request = create(:verification_request)
    branch_result = BranchingRuleEvaluator::Result.new(branch_key: "manual", matched_rule: "fallback", matched_conditions: [], reason: "fallback")
    evidence_result = ConditionalEvidenceRequirementEvaluator::Result.new(required_evidence: ["attestation_statement"], missing_evidence: ["attestation_statement"])

    expect do
      described_class.new(verification_request: request).record!(branch_result:, evidence_result:)
    end.to change { request.verification_events.count }.by(1)

    event = request.verification_events.last
    expect(event.event_type).to eq("branch_decision_recorded")
    expect(event.payload["branch_key"]).to eq("manual")
  end
end
