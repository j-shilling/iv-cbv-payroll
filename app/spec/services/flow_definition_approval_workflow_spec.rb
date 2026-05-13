require "rails_helper"

RSpec.describe FlowDefinitionApprovalWorkflow do
  let(:objective) { create(:verification_objective) }
  let(:flow_definition) { create(:flow_definition, verification_objective: objective) }

  it "returns an error when policy approval is missing" do
    result = described_class.new(flow_definition, approvals: {
      "product" => { "approved_by" => "prod-user", "approved_at" => Time.current.iso8601 }
    }).validate_and_record!

    expect(result.success?).to be(false)
    expect(result.errors.first).to include("policy")
  end

  it "records an audit event when both approvals are present" do
    approvals = {
      "product" => { "approved_by" => "prod-user", "approved_at" => Time.current.iso8601 },
      "policy" => { "approved_by" => "policy-user", "approved_at" => Time.current.iso8601 }
    }

    expect do
      result = described_class.new(flow_definition, approvals: approvals).validate_and_record!
      expect(result.success?).to be(true)
    end.to change(FlowDefinitionAuditEvent, :count).by(1)
  end
end
